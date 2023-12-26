using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthUpScript : MonoBehaviour
{
    public void ActivateLevelUp()
    {
        // Increase health in HealthManager if health is less than maximum
        if (HealthManager.health < HealthManager.maxHealth)
        {
            HealthManager.health++;
        }
    }
}
