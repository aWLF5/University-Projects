using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseCamScript : MonoBehaviour
{
    public GameObject target;


    void Start()
    {
        // Only enable script if there is a target assigned
        if (target == null)
        {
            this.enabled = false;
        }

    }

    // Setting the camera position to the target and following it
    void Update()
    {
        Vector3 position = target.transform.position;
        position.z = -1;
        transform.position = position;
    }
}
