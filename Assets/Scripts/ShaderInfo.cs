using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ShaderInfo : MonoBehaviour {
    public TextMeshProUGUI info;
    public Transform toys;
    
    private void Start() {
        for (var i = 0; i < toys.childCount; ++i) {
            var c = toys.GetChild(i);
            if (c.gameObject.activeSelf) {
                var name = c.gameObject.name.Split("-")[1];
                info.text = $"@硬核酱果 (PORTED FROM SHADERTOY / {name})";
                break;
            }
        }    
    }
}
