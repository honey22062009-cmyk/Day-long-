using UnityEngine;
using UnityEngine.EventSystems;

/// <summary>
/// Collects drag movement from a transparent UI image.
/// The camera reads the accumulated delta with ConsumeDelta().
/// </summary>
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

    private void OnDisable()
    {
        activePointerId = int.MinValue;
        pendingDelta = Vector2.zero;
    }
}
