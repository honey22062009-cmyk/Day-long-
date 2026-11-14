using UnityEngine;
using UnityEngine.EventSystems;

/// <summary>
/// A simple on-screen joystick for touch movement.
/// Place this on the joystick background Image.
/// </summary>
[DisallowMultipleComponent]
public sealed class MobileJoystick : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    [SerializeField] private RectTransform background;
    [SerializeField] private RectTransform handle;

    public Vector2 Direction { get; private set; }

    private int activePointerId = int.MinValue;

    private void Awake()
    {
        if (background == null)
            background = transform as RectTransform;

        ResetJoystick();
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        if (activePointerId != int.MinValue)
            return;

        activePointerId = eventData.pointerId;
        UpdateJoystick(eventData);
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (eventData.pointerId != activePointerId)
            return;

        UpdateJoystick(eventData);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (eventData.pointerId != activePointerId)
            return;

        activePointerId = int.MinValue;
        ResetJoystick();
    }

    private void UpdateJoystick(PointerEventData eventData)
    {
        if (background == null)
            return;

        if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(
                background, eventData.position, eventData.pressEventCamera, out Vector2 localPoint))
            return;

        Rect rect = background.rect;
        float radius = Mathf.Min(rect.width, rect.height) * 0.5f;
        if (radius <= 0f)
            return;

        Direction = Vector2.ClampMagnitude(localPoint / radius, 1f);

        if (handle != null)
        {
            float handleRadius = Mathf.Max(handle.rect.width, handle.rect.height) * 0.5f;
            float travel = Mathf.Max(0f, radius - handleRadius);
            handle.anchoredPosition = Direction * travel;
        }
    }

    private void ResetJoystick()
    {
        Direction = Vector2.zero;

        if (handle != null)
            handle.anchoredPosition = Vector2.zero;
    }

    private void ResetInput()
    {
        activePointerId = int.MinValue;
        ResetJoystick();
    }

    private void OnDisable()
    {
        ResetInput();
    }

    private void OnApplicationFocus(bool hasFocus)
    {
        if (!hasFocus)
            ResetInput();
    }

    private void OnApplicationPause(bool pauseStatus)
    {
        if (pauseStatus)
            ResetInput();
    }
}
