using UnityEngine;
using UnityEngine.UI;

public class CountdownTimer : MonoBehaviour
{
    public float countdownDuration = 300f;
    private Text timeText;
    public GameObject LoseCanvas;
    private PlayerManager playerManager;

    void Start()
    {
        // Start timer text
        timeText = GetComponent<Text>();
        UpdateTimerText();

        // Get player manager to load lose screen if timer runs out
        playerManager = FindObjectOfType<PlayerManager>();
    }

    void Update()
    {
        // Update countdown duration if it is not below 0
        if (countdownDuration > 0f)
        {
            countdownDuration -= Time.deltaTime;

            countdownDuration = Mathf.Max(0f, countdownDuration);

            UpdateTimerText();
        }

        // Trigger game over screen if countdown hits 0
        else
        {
            if (playerManager != null)
            {
                playerManager.SetGameOver(true);
            }
        }
    }

    // Update the UI Text with the current countdown value
    void UpdateTimerText()
    {
        timeText.text = "Game ends in: " + Mathf.CeilToInt(countdownDuration).ToString();
    }
}
