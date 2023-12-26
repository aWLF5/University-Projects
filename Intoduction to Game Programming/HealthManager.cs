using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthManager : MonoBehaviour
{
    // Static variables are shared among all instances of the class
    public static int health;
    public static int maxHealth = 3;

    // Hearts UI elements
    public Image[] hearts;
    public Sprite fullHeart;
    public Sprite emptyHeart;

    private void Awake()
    {
        // Set initial health to max health
        health = maxHealth;
    }

    // Update is called once per frame
    void Update()
    {
        // Update heart UI depending on the current health
        foreach (Image heartImage in hearts)
        {
            // Get the index of the current heartImage in the hearts array
            int currentIndex = System.Array.IndexOf(hearts, heartImage);

            // Display a full heart if its index is less than the current health
            if (currentIndex < health)
            {
                heartImage.sprite = fullHeart;
            }

            // Display an empty heart if its index is greater than or equal to the current health
            else
            {
                heartImage.sprite = emptyHeart;
            }
        }

        // Check if the player's health is below zero to set game over to truein the PlayerManager script
        if (health <= 0)
        {
            PlayerManager playerManager = GetComponent<PlayerManager>();
            playerManager.SetGameOver(true);
        }
    }
}
