using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CreatingCharacters.Abilities
{

    public abstract class Ability : MonoBehaviour
    {
        [SerializeField] private string abilityName = "Espadazo";
        [SerializeField] private string abilityDesc = "Mete un golpe lateral con tu espada";
        [SerializeField] private float abilityCooldown = 1f;
        [SerializeField] private KeyCode abilityKey;

        public abstract void Cast();
    }
}
