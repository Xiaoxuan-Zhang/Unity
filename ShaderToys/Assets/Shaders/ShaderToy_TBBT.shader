Shader "Unlit/ShaderToy_TBBT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        iMouse ("MousePosition", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}
        iResolution0("iResolution", Vector) = (100, 100, 0, 0)
    }
    CGINCLUDE
    #pragma vertex vert
    #pragma fragment frag

    #include "UnityCG.cginc"
    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iTime _Time.y
    #define iResolution _ScreenParams
    #define gl_FragCoord ((iParam.screenPos.xy/iParam.screenPos.w) * _ScreenParams.xy)
    #define MATH_PI 3.14159265358979
    #define EPSILON 0.0001
    #define MAX_STEPS 60
    #define MAX_DIST 100.0
    #define LIGHTBLUE vec3(154.0, 247.0, 247.0)/255.0
    #define GREEN vec3(125.0, 245.0, 217.0)/255.0
    #define YELLOW vec3(0.2, 0.2, 0.0)
    #define PINK vec3(255.0, 94.0, 186.0)/255.0
    #define BLINN 1
    #define AA 0


    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float4 screenPos : TEXCOORD0;
        float4 pos : SV_POSITION;
    };

    struct Material {
        vec3 ambient;
        vec3 diffuse;
        vec3 specular;
        float shiness;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;
    fixed4 iMouse;
    sampler2D iChannel0;
    fixed4 iResolution0;

    vec4 main(vec2 fragCoord);

    v2f vert (appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.screenPos = ComputeScreenPos(o.pos);
        return o;
    }

    fixed4 frag (v2f iParam) : SV_Target
    {
        vec2 fragCoord = gl_FragCoord;
        return main(fragCoord);
    }

    vec4 main(vec2 fragCoord)
    {
        return vec4(1,1,1,1);
    }

    ENDCG
    SubShader
    {
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        } 
    }
}
