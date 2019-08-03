using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderToySupport : MonoBehaviour
{
    private Material m_Material;
    private bool m_IsDragging;
    private Vector3 m_MousePos;
    private Vector3 m_CameraPos;
    private float m_Delta = 1.0f;

    // Start is called before the first frame update
    void Start()
    {
        m_IsDragging = false;
        m_CameraPos = new Vector3(0.0f, 0.0f, 0.0f);
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null) 
        {
            m_Material = renderer.material;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (m_IsDragging)
        {
            m_MousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
        } else 
        {
            m_MousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0.0f);
        }

        if (Input.GetKey(KeyCode.A))
        {
            m_CameraPos.x -= m_Delta;
            Debug.Log("Key A down:" + m_CameraPos);
        }
        if (Input.GetKey(KeyCode.D))
        {
            m_CameraPos.x += m_Delta;
            Debug.Log("Key D down:" + m_CameraPos);
        }

        if (Input.GetKey(KeyCode.S))
        {
            m_CameraPos.z -= m_Delta;
            Debug.Log("Key W down:" + m_CameraPos);
        }
        if (Input.GetKey(KeyCode.W))
        {
            m_CameraPos.z += m_Delta;
            Debug.Log("Key S down:" + m_CameraPos);
        }

        if (m_Material != null)
        {
            m_Material.SetVector("iMouse", m_MousePos);
            m_Material.SetVector("iCameraPos", m_CameraPos);
        }

    }

	private void OnMouseDown()
	{
        m_IsDragging = true;
	}

	private void OnMouseUp()
	{
        m_IsDragging = false;
	}

}
