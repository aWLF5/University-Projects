using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCollision : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D collision)
    {
        // If Enemy is collided with, decrease player's health and trigger the GetHurt animation
        if (collision.transform.tag == "Enemy")
        {
            HealthManager.health--;
            StartCoroutine(GetHurt());
        }

        // If HealthUp object is collided with, activate level up in HealthUp script and destroy the object
        if (collision.transform.tag == "HealthUp")
        {
            HealthUpScript healthUpScript = collision.transform.GetComponent<HealthUpScript>();
            healthUpScript.ActivateLevelUp();
            Destroy(collision.gameObject);
        }
    }

    // Coroutine to disable interactions between player and enemy layers, and enable GetHurt animation for 3 seconds 
    IEnumerator GetHurt()
    {
        Physics2D.IgnoreLayerCollision(7, 8);
        GetComponent<Animator>().SetLayerWeight(1, 1);
        yield return new WaitForSeconds(3);
        GetComponent<Animator>().SetLayerWeight(1, 0);
        Physics2D.IgnoreLayerCollision(7, 8, false);
    }
}
