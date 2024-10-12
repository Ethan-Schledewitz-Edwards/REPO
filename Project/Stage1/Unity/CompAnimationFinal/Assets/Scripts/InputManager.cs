using UnityEngine;

public class InputManager : MonoBehaviour
{
	public static InputManager Instance;

	[Header("System")]
	public Controls controls;

	private void Awake()
	{
		controls = new Controls();
		controls.Enable();

		Instance = this;

        // Subscribe permanent buttons
        // controls.Permanents.Pause.performed += GetComponentInChildren<UIManager>().PauseMenu.PauseInput;
    }

	#region Modes
	/// <summary>
	/// This method sets the games control type
	/// </summary>
	public void ControlMode(ControlType controlType)
	{
		controls.UI.Disable();
		controls.Player.Disable();

		switch (controlType)
		{
			case ControlType.Player:
				controls.Player.Enable();
				break;


			case ControlType.UI:
				controls.UI.Enable();
				break;

			case ControlType.Disabled:
				break;
		}
	}

	public enum ControlType
	{
		Player,
		UI,
		Disabled
	}
	#endregion
}
