using UnityEngine;
using UnityEngine.EventSystems;

/// <summary>
/// Attach to a UI Image to turn it into a one-press jump control.
/// </summary>
public sealed class MobileJumpButton : MonoBehaviour, IPointerDownHandler
{
    private bool jumpRequested;

    public void OnPointerDown(PointerEventData eventData)
    {
        jumpRequested = true;
    }

    public bool ConsumeJumpRequest()
    {
        if (!jumpRequested)
            return false;

        jumpRequested = false;
        return true;
    }

    private void OnDisable()
    {
        jumpRequested = false;
    }
}
