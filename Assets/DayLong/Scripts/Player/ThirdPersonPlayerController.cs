using UnityEngine;

/// <summary>
/// Camera-relative movement for a CharacterController.
/// Movement comes from the on-screen joystick and jump button.
/// </summary>
[DisallowMultipleComponent]
[RequireComponent(typeof(CharacterController))]
public sealed class ThirdPersonPlayerController : MonoBehaviour
{
    [Header("Touch Controls")]
    [SerializeField] private MobileJoystick movementJoystick;
    [SerializeField] private MobileJumpButton jumpButton;

    [Header("Camera")]
    [SerializeField] private Transform cameraTransform;

    [Header("Movement")]
    [SerializeField, Min(0f)] private float moveSpeed = 4.5f;
    [SerializeField, Min(0f)] private float turnSpeed = 540f;
    [SerializeField, Min(0f)] private float jumpHeight = 1.2f;
    [SerializeField] private float gravity = -20f;

    private CharacterController characterController;
    private float verticalVelocity;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();

        if (movementJoystick == null)
            Debug.LogWarning("ThirdPersonPlayerController: Assign a MobileJoystick in the Inspector.", this);

        if (jumpButton == null)
            Debug.LogWarning("ThirdPersonPlayerController: Assign a MobileJumpButton in the Inspector.", this);

        if (cameraTransform == null)
            Debug.LogWarning("ThirdPersonPlayerController: Assign the Main Camera Transform in the Inspector.", this);
    }

    private void OnValidate()
    {
        moveSpeed = Mathf.Max(0f, moveSpeed);
        turnSpeed = Mathf.Max(0f, turnSpeed);
        jumpHeight = Mathf.Max(0f, jumpHeight);
        gravity = -Mathf.Max(0.01f, Mathf.Abs(gravity));
    }

    private void Update()
    {
        float deltaTime = Time.deltaTime;
        Vector2 input = movementJoystick != null ? movementJoystick.Direction : Vector2.zero;
        Vector3 movement = BuildCameraRelativeMovement(input);

        if (movement.sqrMagnitude > 0.001f)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(
                transform.rotation, targetRotation, turnSpeed * deltaTime);
        }

        bool grounded = characterController.isGrounded;

        // Always consume the tap. A tap made while airborne must not trigger on landing.
        bool jumpPressed = jumpButton != null && jumpButton.ConsumeJumpRequest();

        if (grounded && verticalVelocity < 0f)
            verticalVelocity = -2f;

        if (grounded && jumpPressed)
        {
            float gravityMagnitude = Mathf.Max(0.01f, Mathf.Abs(gravity));
            verticalVelocity = Mathf.Sqrt(jumpHeight * 2f * gravityMagnitude);
        }

        verticalVelocity += gravity * deltaTime;

        Vector3 velocity = movement * moveSpeed;
        velocity.y = verticalVelocity;
        characterController.Move(velocity * deltaTime);
    }

    private Vector3 BuildCameraRelativeMovement(Vector2 input)
    {
        Transform reference = cameraTransform != null ? cameraTransform : transform;
        Vector3 forward = Vector3.ProjectOnPlane(reference.forward, Vector3.up).normalized;
        Vector3 right = Vector3.ProjectOnPlane(reference.right, Vector3.up).normalized;
        Vector3 movement = forward * input.y + right * input.x;

        if (movement.sqrMagnitude > 1f)
            movement.Normalize();

        return movement;
    }

    public void SetCameraTransform(Transform newCameraTransform)
    {
        cameraTransform = newCameraTransform;
    }
}
