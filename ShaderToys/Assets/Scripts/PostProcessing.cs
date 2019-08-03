using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour
{
    private Material m_Material;
    private Vector3 m_CameraPos;
    private Vector3 m_MousePos;
    private bool m_IsDragging;
    private float m_Delta = 1.0f;

    private void Start()
    {
        m_CameraPos = new Vector3(0.0f, 0.0f, 0.0f);
        m_IsDragging = false;
        m_Material = new Material(Shader.Find("Hidden/PostProcessing_ShaderToy"));
    }

	private void Update()
	{
        if (m_IsDragging)
        {
            m_MousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
        } 
        else
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
        Debug.Log("Mouse down");
	}

	private void OnMouseUp()
	{
        m_IsDragging = false;
        Debug.Log("Mouse up");
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, m_Material);
    }
}
