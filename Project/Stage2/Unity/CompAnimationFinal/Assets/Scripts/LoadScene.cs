using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScene : MonoBehaviour
{
    [SerializeField] private Animator animator;

    public void LoadSceneEvent()
    {
        SceneManager.LoadScene(1);
    }

    public void LoadScenePress()
    {
        animator.SetTrigger("FadeIn");
    }
}
