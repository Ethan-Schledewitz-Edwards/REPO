public interface IInputHandler
{
    /// <summary>
    /// Toggles a classes input subscription
    /// </summary>
    /// <param name="isInputEnabled">If input is enabled</param>
    public abstract void SetControlsSubscription(bool isInputEnabled);

    /// <summary>
    /// Subscribes to input methods
    /// </summary>
    public abstract void Subscribe();

    /// <summary>
    /// Un-Subscribes from input methods
    /// </summary>
    public abstract void Unsubscribe();
}
