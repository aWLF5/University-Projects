using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerManager : MonoBehaviour
{
    private bool isGameOver = false;
    public GameObject LoseCanvas;
    private bool canvasActivated = false;

    // Call the GameOver method if isGameOver is true
    void Update()
    {
        if (isGameOver)
        {
            GameOver();
        }

    }

    // GameOver method that activates the LoseCanvas and disables the player and the time
    public void GameOver()
    {
        if (!canvasActivated)
        {
            Canvas canvas = LoseCanvas.GetComponent<Canvas>();

            if (canvas != null)
            {
                canvas.sortingOrder = 999;
                canvas.enabled = true;
                canvasActivated = true;

                MovementScript movementScript = GetComponent<MovementScript>();
                if (movementScript != null)
                {
                    movementScript.enabled = false;
                }
                else
                {
                    Debug.LogError("MovementScript component not found on the player.");
                }

                Time.timeScale = 0;
            }
            else
            {
                Debug.LogError("Canvas component seems to be missing.");
            }
        }
    }

    public void SetGameOver(bool value)
    {
        isGameOver = value;
    }

}