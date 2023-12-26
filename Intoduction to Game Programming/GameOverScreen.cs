using UnityEngine;

public class GameOverScreen : MonoBehaviour
{
    public string playerTag = "Player";
    public GameObject EndCanvas;
    private bool canvasActivated = false;

    // Activate EndCanvas if game is over
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag(playerTag) && !canvasActivated)
        {
            Canvas canvas = EndCanvas.GetComponent<Canvas>();
            if (canvas != null)
            {
                canvas.enabled = true;
                canvasActivated = true;
            }
            else
            {
                Debug.LogError("EndCanvas is missing the Canvas component.");
            }
        }
    }
}
