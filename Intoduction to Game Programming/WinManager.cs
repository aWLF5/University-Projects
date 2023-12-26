using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public string playerTag = "Player";
    public MovementScript player;
    public GameObject WinCanvas;
    private bool WinCanvasActivated = false;

    // Let win canvas pop up if player hits the finish pole and disable player and time
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag(playerTag))
        {
            if (!WinCanvasActivated)
            {
                Canvas WCanvas = WinCanvas.GetComponent<Canvas>();

                if (WCanvas != null)
                {
                    WCanvas.sortingOrder = 999;
                    WCanvas.enabled = true;
                    WinCanvasActivated = true;
                    player.enabled = false;
                    Time.timeScale = 0;
                }
                else
                {
                    Debug.LogError("WinCanvas is missing the Canvas component.");
                }
            }
        }
    }

    // Restart Button Behavior
    public void RestartButton()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        Time.timeScale = 1;

    }

    // Menu Button Behavior
    public void MenuButton()
    {
        SceneManager.LoadScene(1);
    }

}
