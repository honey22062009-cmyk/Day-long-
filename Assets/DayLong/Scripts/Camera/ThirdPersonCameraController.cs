using UnityEngine;

/// <summary>
/// Lightweight third-person follow camera controlled by a touch drag area.
/// This keeps Phase 1 independent from extra camera packages.
/// </summary>
public sealed class ThirdPersonCameraController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform followTarget;
    [SerializeField] private MobileLookArea lookArea;

    [Header("Orbit")]
    [SerializeField, Min(0.1f)] private float distance = 5f;
    [SerializeField, Min(0f)] private float targetHeight = 1.5f;
    [SerializeField] private float startingPitch = 12f;
    [SerializeField] private float minimumPitch = -10f;
    [SerializeField] private float maximumPitch = 55f;
    [SerializeField, Min(0f)] private float sensitivity = 0.12f;

    [Header("Smoothing")]
    [SerializeField, Min(0f)] private float followSmoothTime = 0.08f;
    [SerializeField, Min(0f)] private float rotationSharpness = 18f;

    private float yaw;
    private float pitch;
    private Vector3 positionVelocity;

    private void Awake()
    {
        if (followTarget != null)
            yaw = followTarget.eulerAngles.y;

        pitch = Mathf.Clamp(startingPitch, minimumPitch, maximumPitch);

        if (followTarget != null)
            SnapToTarget();
    }

    private void LateUpdate()
    {
        if (followTarget == null)
            return;

        if (lookArea != null)
        {
            Vector2 drag = lookArea.ConsumeDelta();
            yaw += drag.x * sensitivity;
            pitch = Mathf.Clamp(pitch - drag.y * sensitivity, minimumPitch, maximumPitch);
        }

        Quaternion orbitRotation = Quaternion.Euler(pitch, yaw, 0f);
        Vector3 focusPoint = followTarget.position + Vector3.up * targetHeight;
        Vector3 desiredPosition = focusPoint - orbitRotation * Vector3.forward * distance;

        transform.position = Vector3.SmoothDamp(
            transform.position, desiredPosition, ref positionVelocity, followSmoothTime);

        Quaternion desiredRotation = Quaternion.LookRotation(
            focusPoint - transform.position, Vector3.up);

        float blend = 1f - Mathf.Exp(-rotationSharpness * Time.deltaTime);
        transform.rotation = Quaternion.Slerp(transform.rotation, desiredRotation, blend);
    }

    private void SnapToTarget()
    {
        Quaternion orbitRotation = Quaternion.Euler(pitch, yaw, 0f);
        Vector3 focusPoint = followTarget.position + Vector3.up * targetHeight;
        transform.position = focusPoint - orbitRotation * Vector3.forward * distance;
        transform.rotation = Quaternion.LookRotation(focusPoint - transform.position, Vector3.up);
    }

    public void SetFollowTarget(Transform target)
    {
        followTarget = target;
        positionVelocity = Vector3.zero;

        if (followTarget != null)
        {
            yaw = followTarget.eulerAngles.y;
            SnapToTarget();
        }
    }

    public void SetLookArea(MobileLookArea area)
    {
        lookArea = area;
    }
}
