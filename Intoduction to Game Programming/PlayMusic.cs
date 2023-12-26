using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class RandomMusicPlayer : MonoBehaviour
{
    public List<AudioClip> musicList;
    private AudioSource audioSource;

    // Get the AudioSource component attached to this GameObject and play a random track
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        PlayRandomMusic();
    }

    // Play a random track from the musicList
    void PlayRandomMusic()
    {
        if (musicList.Count > 0)
        {
            // Select a random audio clip from the list
            AudioClip randomAudioClip = musicList[Random.Range(0, musicList.Count)];

            // Play the selected audio clip
            audioSource.clip = randomAudioClip;
            audioSource.Play();
        }
        else
        {
            Debug.LogError("No audio clips in the music list. Add audio clips in the Unity Editor.");
        }
    }
}
