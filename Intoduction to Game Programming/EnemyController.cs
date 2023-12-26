using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class EnemyController : MonoBehaviour
{
    // Variables for waypoints and target
    public GameObject[] waypoints;
    public GameObject target;
    public int iterator = 0;

    // Reference to SpriteRenderer component
    private SpriteRenderer spRend;

    // Health variables
    private int health = 3;
    public GameObject healthUpPrefab;


    void Start()
    {
        // Initialize target with the first waypoint
        target = waypoints[0];

        // Get the SpriteRenderer component
        spRend = GetComponent<SpriteRenderer>();
    }


    void Update()
    {
        // Get destination and current position of Enemy
        Vector3 dest = target.transform.position;
        Vector3 pos = transform.position;

        // Calculate distance to move, and move towards destination (i.e. waypoints)
        float distance = 2 * Time.deltaTime;

        if (pos.x > dest.x)
        {
            pos.x -= distance;
            spRend.flipX = false;
        }
        else
        {
            pos.x += distance;
            spRend.flipX = true;
        }

        transform.position = pos;

        // Trigger NextWaypoint function if enemy reaches destination
        if (Mathf.Abs(pos.x - dest.x) < distance)
        {
            NextWaypoint();
        }

    }

    // Function to switch to the next waypoint
    private void NextWaypoint()
    {
        iterator++;
        iterator = iterator % waypoints.Length;
        target = waypoints[iterator];
    }

    // Take damage function: when health is empty, enemy gets destroyed and HealthUp prefab appears
    public void TakeDamage(int damage)
    {
        health -= damage;
        if (health <= 0)
        {
            Destroy(gameObject);
            Instantiate(healthUpPrefab, transform.position, Quaternion.identity);
        }
    }
}
