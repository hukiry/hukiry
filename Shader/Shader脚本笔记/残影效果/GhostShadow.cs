using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GhostShadow : MonoBehaviour
{
    //持续时间
    public float duration = 2f;
    //创建新残影间隔
    public float interval = 0.1f;

    //边缘颜色强度
    [Range(-1, 2)]
    public float Intension = 1;

    //网格数据
    SkinnedMeshRenderer[] meshRender;

    //X-ray
    Shader ghostShader;

    void Start()
    {
        //获取身上所有的Mesh
        meshRender = this.gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

        ghostShader = Shader.Find("lijia/Xray");
    }

    private float lastTime = 0;

    private Vector3 lastPos = Vector3.zero;

    void Update()
    {
        //人物有位移才创建残影
        if (lastPos == this.transform.position)
        {
            return;
        }
        lastPos = this.transform.position;
        if (Time.time - lastTime < interval)
        {//残影间隔时间
            return;
        }
        lastTime = Time.time;

        if (meshRender == null)
            return;
        for (int i = 0; i < meshRender.Length; i++)
        {
            Mesh mesh = new Mesh();
            meshRender[i].BakeMesh(mesh);

            GameObject go = new GameObject();
            go.hideFlags = HideFlags.HideAndDontSave;

            GhostItem item = go.AddComponent<GhostItem>();//控制残影消失
            item.duration = duration;
            item.deleteTime = Time.time + duration;

            MeshFilter filter = go.AddComponent<MeshFilter>();
            filter.mesh = mesh;

            MeshRenderer meshRen = go.AddComponent<MeshRenderer>();

            meshRen.material = meshRender[i].material;
            meshRen.material.shader = ghostShader;//设置xray效果
            meshRen.material.SetFloat("_Intension", Intension);//颜色强度传入shader中

            go.transform.localScale = meshRender[i].transform.localScale;
            go.transform.position = meshRender[i].transform.position;
            go.transform.rotation = meshRender[i].transform.rotation;

            item.meshRenderer = meshRen;
        }
    }
}
