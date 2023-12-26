using UnityEngine;

public class PlayerOutOfBounds : MonoBehaviour
{
    public string outOfBoundsTag = "OutOfBounds";
    public GameObject LoseCanvas;

    // Set game over to true in the player manager if the player collides with the out of bounds game object
    private void OnCollisionEnter2D(Collision2D collision)
    {
        PlayerManager playerManager = GetComponent<PlayerManager>();

        if (collision.gameObject.CompareTag(outOfBoundsTag))
        {
            playerManager.SetGameOver(true);
        }
    }
}