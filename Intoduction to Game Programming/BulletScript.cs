using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletScript : MonoBehaviour
{
    public float speed;
    private Rigidbody2D rb;
    public float destroyTime = 3f;


    void Start()
    {
        // Adding velocity to bullet
        rb = GetComponent<Rigidbody2D>();
        rb.velocity = transform.right * speed;

        // Start delay coroutine
        StartCoroutine(DestroyBulletAfterDelay());
    }

    // Behavior when bullet hits enemy: enemy takes 1 damage and bullet gets destroyed
    private void OnTriggerEnter2D(Collider2D collision)
    {
        EnemyController enemy = collision.GetComponent<EnemyController>();
        if (collision.transform.tag == "Enemy")
        {
            enemy.TakeDamage(1);
            Destroy(gameObject);
        }
    }

    // Coroutine to destroy the bullet after a specified delay
    private IEnumerator DestroyBulletAfterDelay()
    {
        yield return new WaitForSeconds(destroyTime);
        Destroy(gameObject);
    }

}
