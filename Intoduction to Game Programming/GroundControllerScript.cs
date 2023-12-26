using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class GroundControllerScript : MonoBehaviour
{
    // SerializeField tells Unity to display the variable in the inspector
    [SerializeField] private bool grounded = false;

    // Get centre and edges when collision happens
    private void OnCollisionStay2D(Collision2D collision)
    {
        var collisionCentre = GetMidpoint(collision);
        DetectEdge(collisionCentre);

    }

    // Reset grounded to false when collision is exited
    private void OnCollisionExit2D(Collision2D collision)
    {
        grounded = false;
    }

    // Method to calculate the midpoint of a collision
    private Vector2 GetMidpoint(Collision2D collision)
    {
        Vector2 midpoint = Vector2.zero;
        var collisions = collision.contactCount;
        for (int i = 0; i < collisions; i++)
        {
            midpoint += collision.GetContact(i).point;
        }
        return midpoint / collisions;
    }

    // Detect if the collision happens on the ground
    private void DetectEdge(Vector2 collisionCentre)
    {
        var pos = transform.position;
        var halfWidth = transform.localScale.x / 2;
        grounded = collisionCentre.y < pos.y;
    }

    // Accessor method for the grounded variable
    public bool IsGrounded()
    {
        return grounded;
    }

}
