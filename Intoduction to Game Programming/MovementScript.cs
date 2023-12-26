using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class MovementScript : MonoBehaviour
{
    // Input settings
    public InputActionAsset playerControls;
    private InputAction move;
    private InputAction jump;

    // Movement settings
    public Transform BoyTransform;
    public float movementSpeed = 1;
    private Animator animator;

    // Jump settings
    public Rigidbody2D BoyRigidbody;
    public float JumpStrength = 1;

    // Ground detection
    public GroundControllerScript ground;

    private bool isFacingRight = true;

    void Start()
    {
        // Get Animator component for character animation
        animator = gameObject.GetComponent<Animator>();
    }

    private void Awake()
    {
        // Initialize move and jump actions
        move = playerControls.FindAction("move");
        jump = playerControls.FindAction("jump");
    }

    private void OnEnable()
    {
        // Enable move and jump actions
        move.Enable();
        jump.Enable();
    }

    private void OnDisable()
    {
        // Disable move and jump actions
        move.Disable();
        jump.Disable();
    }

    void Update()
    {
        // Current position of the character
        Vector3 pos = BoyTransform.position;

        // Calculate the distance the object should move during this frame
        var distance = movementSpeed * Time.deltaTime;

        // Read the value of the move action, i.e., the direction of movement (left or right)
        var direction = move.ReadValue<float>();

        // Flip the character's x direction based on the movement input
        if (direction > 0 && !isFacingRight)
        {
            // Moving right, and not currently facing right
            Flip();
        }
        else if (direction < 0 && isFacingRight)
        {
            // Moving left, and not currently facing left
            Flip();
        }

        // Move the character
        pos.x += direction * distance;
        BoyTransform.position = pos;

        // Set the "isRunning" parameter in the animator based on the movement input
        animator.SetBool("isRunning", direction != 0);

        // Jump behavior (only possible when character is grounded)
        if (ground.IsGrounded() && jump.WasPressedThisFrame())
        {
            // Apply upward force for jumping
            BoyRigidbody.AddForce(Vector2.up * JumpStrength, ForceMode2D.Impulse);
            animator.SetBool("isJumping", true);
            StartCoroutine(ResetIsJumping());
        }

        // Coroutine to reset isJumping after 0.5 seconds
        IEnumerator ResetIsJumping()
        {
            yield return new WaitForSeconds(0.5f);
            animator.SetBool("isJumping", false);
        }

        // Falling behavior 
        animator.SetBool("isFalling", BoyRigidbody.velocity.y < 0 && !ground.IsGrounded());
    }

    // Function to flip the character's Y-axis rotation
    private void Flip()
    {
        isFacingRight = !isFacingRight;

        // Flip the Y-axis rotation by adding 180 degrees
        BoyTransform.Rotate(0, 180, 0);
    }
}
