using UnityEngine;
using UnityEngine.SceneManagement;


public class StartGameScript : MonoBehaviour
{
    // Pressing the Start Game button in the main menu starts the game 
    public void StartGame()
    {
        SceneManager.LoadScene(0);
        Time.timeScale = 1;
    }

}
