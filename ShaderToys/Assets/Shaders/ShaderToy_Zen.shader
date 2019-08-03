Shader "Unlit/ShaderToy_Zen"
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
    #define iGlobalTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((iParam.screenPos.xy/iParam.screenPos.w) * _ScreenParams.xy)
    #define MATH_PI 3.14159265358979
    #define PURPLE vec3(1.0, 0.9, 1.0)
    #define PINK vec3(0.5, 0.4, 0.4)
    #define WHITE vec3(1.0, 1.0, 1.0)
    #define BLACK vec3(0.0, 0.0, 0.0)
    #define SKY vec3(0.0, 0.0, 0.0)
    #define MOON vec3(1.0, 0.6, 0.0)
    #define BLUE vec3(0.1, 0.2, 0.3)
    #define GREEN vec3(0.1, 0.2, 0.3)
    #define EARTH vec3(0.1, 0.1, 0.1)
    #define EPSILON 0.0001
    #define SCALE 0.01
    #define HEIGHT 12.0
    #define MAX_DISTANCE 1000.0
    #define m2 mat2(1.6,  1.2, -1.2,  1.6)
    #define TURBULENCE 0.04
    #define iTime _Time.y

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

    //noise function from iq: https://www.shadertoy.com/view/Msf3WH
    vec2 hash( vec2 p ) 
    {
        p = vec2( dot(p, vec2(127.1,311.7)), dot(p, vec2(269.5,183.3)) );
        return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
    }

    float noise( vec2 p )
    {
        const float K1 = 0.366025404; // (sqrt(3)-1)/2;
        const float K2 = 0.211324865; // (3-sqrt(3))/6;

        vec2  i = floor(p + (p.x + p.y) * K1);
        vec2  a = p - i + (i.x+i.y) * K2;
        float m = step(a.y, a.x); 
        vec2  o = vec2(m, 1.0 - m);
        vec2  b = a - o + K2;
        vec2  c = a - 1.0 + 2.0 * K2;
        vec3  h = max( 0.5 - vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
        vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
        return dot( n, vec3(70.0, 70.0, 70.0) );
    }

    float fbm(vec2 p) {
        float amp = 0.5;
        float h = 0.0;
        for (int i = 0; i < 8; i++) {
            float n = noise(p);
            h += amp * n;
            amp *= 0.5;
            p = mul(m2, p);
        }
        
        return  0.5 + 0.5*h;
    }

    vec3 smokeEffect(vec2 uv) {
        vec3 col = vec3(0.0, 0.0, 0.0);
        // time scale
        float v = 0.0002;
        vec3 smoke = vec3(1.0, 1.0, 1.0);
        //uv += mo * 10.0; 
       
        vec2 scale = uv * 0.5 ;
        vec2 turbulence = TURBULENCE * vec2(noise(vec2(uv.x * 3.5, uv.y * 3.2)), noise(vec2(uv.x * 2.2, uv.y * 1.5)));
        scale += turbulence;
        float n1 = fbm(vec2(scale.x - abs(sin(iTime * v * 2.0)), scale.y - 50.0 * abs(sin(iTime * v))));
        col =  mix( col, smoke, smoothstep(0.5, 0.9, n1));
        //float y = fragCoord.y/iResolution.y;
        //float fade = exp(-(y*y));
        //col *= fade;
        col = clamp(col, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
        return col;
    }

    float circle(vec2 p, float r) {
        float c = length(p) - r;
        return smoothstep(r + 0.01, r, c);
    }

    float sinwave(vec2 p, float scale, float amp) {
        float wave = cos(p.x * scale + 0.5) + 0.25 * cos(p.x * scale * scale);
        float s = smoothstep(amp + 0.01, amp, amp * wave - p.y);
        return s;
    }

    vec4 main(vec2 fragCoord) 
    {
        vec2 uv = fragCoord/iResolution.xy;
        vec2 p = fragCoord/iResolution.xy;
        p -= 0.5;
        p.x *= iResolution.x / iResolution.y;
        
        vec3 col = vec3(0.0, 0.0, 0.0);    
        vec3 smoke = smokeEffect(p);
        
        vec3 background = 0.7 * vec3(238.0, 232.0, 170.0)/255.0;
        vec3 mountCol = mix(vec3(102.0,153.0,153.0)/255.0, vec3(153.0,204.0,0.0)/255.0, p.y + 0.5);
        vec3 sunCol = 0.85 * mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 1.0, 0.0), p.y + 0.5);
        vec3 cloudCol = vec3(0.9, 0.9, 0.9);
        float t = iTime * 0.05;
        vec2 sunPos = p - vec2(0.4 * cos(t), 0.4 * sin(t));
        float sun = circle(sunPos, 0.1); 
        float mountain1 = sinwave(p - vec2(0.5, -0.1), 3.0, 0.1);
        float mountain2 = sinwave(p, 3.0, 0.2);
        float cloud = 1.0 - smoke.r;
        col = mix(background, sunCol, sun);
        col = mix(mountCol * 0.9, col, mountain1);
        col = mix(cloudCol, col, cloud);
        col = mix(mountCol, col, mountain2);
         
        col *= 0.2 + 0.8 * pow(32.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.2);
        return vec4(col ,1.0);
       
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
