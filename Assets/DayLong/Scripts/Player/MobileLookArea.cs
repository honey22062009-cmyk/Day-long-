using UnityEngine;
using UnityEngine.EventSystems;

/// <summary>
/// Collects drag movement from a transparent UI image.
/// The camera reads the accumulated delta with ConsumeDelta().
/// </summary>
[DisallowMultipleComponent]
public sealed class MobileLookArea : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    private Vector2 pendingDelta;
    private int activePointerId = int.MinValue;

    public void OnPointerDown(PointerEventData eventData)
    {
        if (activePointerId != int.MinValue)
            return;

        activePointerId = eventData.pointerId;
        pendingDelta = Vector2.zero;
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (eventData.pointerId == activePointerId)
            pendingDelta += eventData.delta;
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (eventData.pointerId == activePointerId)
            activePointerId = int.MinValue;
    }

    public Vector2 ConsumeDelta()
    {
        Vector2 result = pendingDelta;
        pendingDelta = Vector2.zero;
        return result;
    }

    private void ResetInput()
    {
        activePointerId = int.MinValue;
        pendingDelta = Vector2.zero;
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
