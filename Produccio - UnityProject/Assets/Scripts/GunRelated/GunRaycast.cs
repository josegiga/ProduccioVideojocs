using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class GunRaycast : MonoBehaviour
{

    public List<GameObject> bulletList;
    public GameObject bullet;
    public int amount;
    public Transform initialPos;
    public float bulletSpeed;
    private float damage;
    public int maxBulletsPerMag = 15;
    public int currentMagazine;
    private float reloadTime = 1.5f;
    private bool fireGun = true;

    public float gunDamage = 1.5f;                                            // Set the number of hitpoints that this gun will take away from shot objects with a health script
    public float fireRate = 0.25f;                                        // Number in seconds which controls how often the player can fire
    public float weaponRange = 50f;                                        // Distance in Unity units over which the player can fire
    public float hitForce = 400f;                                        // Amount of force which will be added to objects with a rigidbody shot by the player
    public Transform gunEnd;                                            // Holds a reference to the gun end object, marking the muzzle location of the gun

    public ParticleSystem muzzleFlash;

    private Camera fpsCam;                                                // Holds a reference to the first person camera
    private WaitForSeconds shotDuration = new WaitForSeconds(0.02f);    // WaitForSeconds object used by our ShotEffect coroutine, determines time laser line will remain visible
    //private AudioSource gunAudio;                                        // Reference to the audio source which will play our shooting sound effect
    //private LineRenderer laserLine;                                        // Reference to the LineRenderer component which will display our laserline
    private float nextFire;                                                // Float to store the time the player will be allowed to fire again, after firing

    //public TMP_Text AmmoCountGUI;
    /*[SerializeField]
    public TextMeshPro AmmoCountGUI;
    private int currentAmmo;*/

    public TextMeshProUGUI currentMagazineUI;

    private AudioSource audioS;

    void Start()
    {

        bulletList = new List<GameObject>();
        for (int i = 0; i < amount; i++)
        {
            GameObject objBullet = (GameObject)Instantiate(bullet);
            objBullet.SetActive(false);
            bulletList.Add(objBullet);
        }
        currentMagazine = maxBulletsPerMag;

        // Get and store a reference to our LineRenderer component
        //laserLine = GetComponent<LineRenderer>();


        // Get and store a reference to our AudioSource component
        //gunAudio = GetComponent<AudioSource>();

        // Get and store a reference to our Camera by searching this GameObject and its parents
        fpsCam = GetComponentInParent<Camera>();

        audioS = GetComponent<AudioSource>();
       
         //currentMagazineUI = GetComponent<TextMeshProUGUI>();
    }


    void Update()
    {
        // Check if the player has pressed the fire button and if enough time has elapsed since they last fired
        if ((Input.GetButtonDown("Fire1") && Time.time > nextFire) && fireGun)
        {
            audioS.Play();
            // Update the time when our player can fire next
            nextFire = Time.time + fireRate;
            Shoot();
            // Start our ShotEffect coroutine to turn our laser line on and off
            StartCoroutine(ShotEffect());
            
            // Create a vector at the center of our camera's viewport
            Vector3 rayOrigin = fpsCam.ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0.0f));

            // Declare a raycast hit to store information about what our raycast has hit
            RaycastHit hit;

            // Set the start position for our visual effect for our laser to the position of gunEnd
            //laserLine.SetPosition(0, gunEnd.position);

            // Check if our raycast has hit anything
            if (Physics.Raycast(rayOrigin, fpsCam.transform.forward, out hit, weaponRange))
            {
                // Set the end position for our laser line 
                //laserLine.SetPosition(1, hit.point);

                // Get a reference to a health script attached to the collider we hit
                Enemy health = hit.collider.GetComponent<Enemy>();

                // If there was a health script attached
                if (health != null)
                {
                    // Call the damage function of that script, passing in our gunDamage variable
                    health.TakeDamage(gunDamage,0);
                }

                // Check if the object we hit has a rigidbody attached
                if (hit.rigidbody != null)
                {
                    // Add force to the rigidbody we hit, in the direction from which it was hit
                    hit.rigidbody.AddForce(-hit.normal * hitForce);                    
                }
            }
            else
            {
                // If we did not hit anything, set the end of the line to a position directly in front of the camera at the distance of weaponRange
                //laserLine.SetPosition(1, rayOrigin + (fpsCam.transform.forward * weaponRange));
            }
            currentMagazine--;
            upDateUIAmmo();
            checkMagazine();
        }
    }

    private void upDateUIAmmo()
    {
        currentMagazineUI.SetText(currentMagazine+"/"+maxBulletsPerMag);
    }

    private void checkMagazine()
    {
        if(currentMagazine <= 0)
        {
            fireGun = false;

            StartCoroutine(ReloadGun());
        }
    }

    private IEnumerator ReloadGun()
    {
        yield return new WaitForSeconds(reloadTime);
        currentMagazine = maxBulletsPerMag;
        upDateUIAmmo();
        fireGun = true;
    }
   /* private IEnumerable ReloadGun()
    {
        fireGun = true;
        yield return reloadTime;
    }*/


    private IEnumerator ShotEffect()
    {
        // Play the shooting sound effect
        //gunAudio.Play();

        // Turn on our line renderer
        //laserLine.enabled = true;
        muzzleFlash.Play();
        yield return shotDuration;

        // Deactivate our line renderer after waiting
        //laserLine.enabled = false;
    }
    void Shoot()
    {
        GameObject currentBullet = getBulletPool();
        currentBullet.transform.position = initialPos.position;
        currentBullet.transform.rotation = initialPos.rotation;
        currentBullet.SetActive(true);
        Rigidbody tempRigidBodyBullet = currentBullet.GetComponent<Rigidbody>();
        tempRigidBodyBullet.angularVelocity = Vector3.zero;
        tempRigidBodyBullet.velocity = Vector3.zero;
        tempRigidBodyBullet.AddForce(tempRigidBodyBullet.transform.forward * bulletSpeed, ForceMode.Impulse);
    }
    private GameObject getBulletPool()
    {
        for (int i = 0; i < bulletList.Count; i++)
        {
            if (!bulletList[i].activeInHierarchy)
            {
                return bulletList[i];
            }

        }
        GameObject objBullet = (GameObject)Instantiate(bullet);
        objBullet.SetActive(false);
        bulletList.Add(objBullet);
        return objBullet;
    }
}