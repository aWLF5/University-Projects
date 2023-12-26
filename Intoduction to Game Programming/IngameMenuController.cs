using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IngameMenuController : MonoBehaviour
{
    // Reference to menu canvas and player's movement script
    public GameObject popupMenu;
    public MovementScript player;

    void Start()
    {
        // Deactivate menu canvas at the start
        popupMenu.SetActive(false);
    }

    void Update()
    {
        // Trigger menu canvas if esc key is pressed
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            // Stop game and activate menu canvas if esc is pressed the first time
            if (Time.timeScale == 0)
            {
                popupMenu.SetActive(false);
                player.enabled = true;
                Time.timeScale = 1;
            }

            // Start game again when esc is pressed the second time
            else
            {
                Time.timeScale = 0;
                popupMenu.SetActive(true);
                player.enabled = false;
            }
        }
    }
}
