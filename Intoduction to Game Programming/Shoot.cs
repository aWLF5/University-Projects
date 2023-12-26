using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Shoot : MonoBehaviour
{
    // Input settings
    public InputActionAsset playerControls;
    private InputAction shoot;

    // Shooting settings
    public Transform ShootingPoint;
    public List<GameObject> bulletPrefabs = new List<GameObject>();
    private float lastShootTime;
    public float shootCooldown = 1f;

    void Awake()
    {
        // Initialize the shoot action
        shoot = playerControls.FindAction("shoot");
    }

    private void OnEnable()
    {
        // Enable the shoot action when this script is enabled
        shoot.Enable();
    }

    private void OnDisable()
    {
        // Disable the shoot action when this script is disabled
        shoot.Disable();
    }

    void Update()
    {
        // Shooting behavior
        if (shoot.WasPressedThisFrame() && Time.time - lastShootTime >= shootCooldown)
        {
            ShootBullet();
        }
    }

    void ShootBullet()
    {
        // Instantiate a random bullet from the list
        int randomIndex = Random.Range(0, bulletPrefabs.Count);
        GameObject bullet = Instantiate(bulletPrefabs[randomIndex], ShootingPoint.position, transform.rotation);

        // Record the time of the last shot for cooldown
        lastShootTime = Time.time;
    }
}
