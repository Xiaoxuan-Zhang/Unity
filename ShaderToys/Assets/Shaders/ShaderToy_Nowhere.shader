Shader "Unlit/ShaderToy_Nowhere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        iMouse ("MousePosition", Vector) = (1, 1, 0, 0)
        iCameraPos("Camera Position", Vector) = (1, 1, 1, 0)
        iChannel0("iChannel0", 2D) = "white" {}
        iResolution0("iResolution", Vector) = (100, 100, 0, 0)
    }
    CGINCLUDE
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
    #define iResolution _ScreenParams
    #define iTime _Time.y
    #define gl_FragCoord ((iParam.screenPos.xy/iParam.screenPos.w) * _ScreenParams.xy)
    #define MATH_PI 3.1415926
    #define MATH_2PI 6.2831854
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
    #define m2 mat2(1.2,  0.8, -0.8,  1.2)

    #define moonDir normalize(vec3(7.0, 1.0, -5.0))

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
    fixed4 iCameraPos;
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
    float hash1(vec2 p)
    {
        vec3 p3  = fract(vec3(p.xyx) * 0.013);
        p3 += dot(p3, p3.yzx + 19.31);
        return -1.0 + 2.0 * fract((p3.x + p3.y) * p3.z);
    }

    float noise(in vec2 x) {
        vec2 p = floor(x);
        vec2 w = fract(x);
        
        vec2 u = w*w*w*(w*(w*6.0-15.0)+10.0);
        
        float a = hash1(p+vec2(0,0));
        float b = hash1(p+vec2(1,0));
        float c = hash1(p+vec2(0,1));
        float d = hash1(p+vec2(1,1));

        float k0 = a;
        float k1 = b - a;
        float k2 = c - a;
        float k4 = a - b - c + d;

        return k0 + k1*u.x + k2*u.y + k4*u.x*u.y;
    }

    vec3 noised( in vec2 x )
    {
        vec2 p = floor(x);
        vec2 w = fract(x);
        
        vec2 u = w*w*w*(w*(w*6.0-15.0)+10.0);
        vec2 du = 30.0*w*w*(w*(w-2.0)+1.0);
        
        float a = hash1(p+vec2(0,0));
        float b = hash1(p+vec2(1,0));
        float c = hash1(p+vec2(0,1));
        float d = hash1(p+vec2(1,1));

        float k0 = a;
        float k1 = b - a;
        float k2 = c - a;
        float k4 = a - b - c + d;

        return vec3( -1.0 + 2.0 * (k0 + k1*u.x + k2*u.y + k4*u.x*u.y), 
                          2.0* du * vec2( k1 + k4*u.y,
                                          k2 + k4*u.x ) );
    }

    float fbm4(vec2 p) {
        float amp = 1.0;
        float h = 0.0;
        for (int i = 0; i < 4; i++) {
            float n = noise(p);
            h += amp * n;
            amp *= 0.5;
            p = mul(m2, p);
        }
        return  h;
    }

    vec4 fbmd4(vec2 v) {
        float amp = 1.0;
        float f = 1.0 ;
        float h = 0.0;
        vec2 d = vec2(0.0, 0.0);
        for (int i = 0; i < 4; i++) {
            vec3 n = noised(v * SCALE * f);
            h += amp * n.x;
            d += amp * n.yz * f;
            amp *= 0.5;
            f *= 1.0;
            v = mul(m2, v);
        }
        h *= HEIGHT  ;
        d *= HEIGHT * SCALE;
        return vec4( h, normalize( vec3(-d.x, 1.0, -d.y) ) );
    }

    vec4 terrainMap(vec3 v) {
        vec4 terrain = fbmd4(v.xz - vec2(100.0, 0.0));
        terrain.x += 0.02 * noise(v.xz * 0.8);
        return terrain;
    }

    vec4 sceneMap(vec3 v) {
        return terrainMap(v);
    }

    vec3 getNormal(vec3 p )
    {
        vec2 OFFSET = vec2(EPSILON, 0.0);
        return normalize( vec3( sceneMap(p-OFFSET.xyy).x-sceneMap(p+OFFSET.xyy).x,
                                1.0 * EPSILON,
                                sceneMap(p-OFFSET.yyx).x-sceneMap(p+OFFSET.yyx).x ) );
    }

    vec3 moon(vec3 ro, vec3 rd) {
        float n1 = 0.3 * noise(rd.xy * 20.0 - iTime);
        float n2 = 0.3 * noise(rd.xy * 10.0 - iTime);
        float sdot = dot(rd, moonDir) * 10.0;
        float s1 = smoothstep(9.4, 9.75, sdot);
        float col1 = pow(s1, 128.0);
        float s2 = smoothstep(9.0+n1, 9.75, sdot);
        float col2 = pow(s2, 64.0);
        float s3 = smoothstep(8.2+n2, 9.7, sdot);
        float col3 = pow(s3, 64.0);
        float hole1 = (col2 -col1);
        float hole2 = (col3 -col1);
        vec3 rst = hole1 * MOON + hole2 * GREEN;
        return rst;
    }

    vec3 stars(vec2 p) {
        float t = iTime * 0.1;
        float n1 = hash1(p*0.1) ;
        n1 *= pow(n1*n1, 680.0) ;
        n1 *= sin(t*5.0 + p.x + sin(t*2.0 + p.y));
        n1 = clamp(n1, 0.0, 1.0);
        return n1 * vec3(1.0, 1.0, 1.0);
    }

    vec3 sky(vec3 ro, vec3 rd) {
        vec3 col = vec3(0.0, 0.0, 0.0);
        vec3 v = ro + rd*MAX_DISTANCE;
        float n1 = noise(v.xy * 0.001);
        float n2 = noise(v.yx * 0.001);
        vec3 skyCol = GREEN * 0.01;
        col += mix(skyCol, GREEN, exp(-16.0*v.y/MAX_DISTANCE));
        col += stars(v.xy);
        col += moon(ro, rd);
        return col;
    }

    vec4 castRay(vec3 ro, vec3 rd) {
        vec4 re = vec4(-1.0, -1.0, -1.0, -1.0);
        float t = 0.0;
        for( int i=0; i<40; i++ ){
            vec3 p = ro + rd * t;
            vec4 n = sceneMap(p);
            float h = p.y - n.x;
            re = vec4(t, n.yzw);
            t += h*n.z; 
            if ((abs(h) < EPSILON) || t > MAX_DISTANCE) {
                break;
            } 
        }
        
        if (t > MAX_DISTANCE) {
            re = vec4(-1.0, -1.0, -1.0, -1.0);
        }
        return re;
    }

    vec3 getShading(vec3 ro, vec3 rd, vec3 p, vec3 normal, vec3 color) {
        vec3 col = vec3(0.0, 0.0, 0.0);
        vec3 lightDir = moonDir;
        float moonAmount = max(dot(rd, lightDir), 0.0);
        vec3 lightCol = mix( GREEN, MOON, pow(moonAmount, 2.0));
        
        vec3 viewDir = normalize(ro - p); 
        vec3 refDir = reflect(-lightDir, normal);
        
        vec3 ambCol = lightCol * 0.1;
        float diff = max(dot(lightDir, normal), 0.0);
        vec3 diffCol = lightCol * diff;
        
        float spec = pow(max(dot(refDir, viewDir), 0.0), 8.0);
        vec3 speCol = lightCol * spec * 0.7;

        col = (speCol + diffCol) * color ;
        return col;
    }

    vec3 getMaterial(vec3 ro, vec3 rd, vec3 p, vec3 normal) {
        vec3 col = vec3(0.3, 0.1, 0.1);
        vec3 lightDir = moonDir;
        //a bit of sprinkling
        if (hash1(p.xz) > 0.995) {
            col += clamp(sin(iTime + p.x*p.z), 0.5, 1.0) * vec3(1.2, 1.2, 1.2);
        }
        
        return col;
    }

    vec3 terrainColor(vec3 ro, vec3 rd, vec3 p, vec3 nor) {
        vec3 col = vec3(0.0, 0.0, 0.0);
        col = getMaterial(ro, rd, p, nor);
        col = getShading(ro, rd, p, nor, col) ;
        
        return col;
    }

    vec3 fog(vec3 ro, vec3 rd, vec3 p, vec3 pixCol, float dis)
    {
        vec3 lightDir = moonDir;
        //base color and moonlight
        vec3 fogCol = vec3(0.0, 0.0, 0.0);
        float b  = 0.000005;
        float fogAmount = 1.0 - exp( -dis*dis*b );
        
        float moonAmount = max(dot(rd, lightDir), 0.0);
        vec3 mixFog = mix(GREEN, MOON*0.5, pow(moonAmount, 16.0));
        fogCol = mix( pixCol, mixFog, fogAmount );
       
        //adding density
        float c = 0.00002;
        float b1 = 0.17;
        float t = iTime ;
        float v = 1.0;
        vec3  denCol  = GREEN; 
        float density =  c * exp(-ro.y*b1) * (1.0 - exp(-dis*rd.y*b1 ))/(rd.y);
        density += 0.05*(fbm4(vec2(p.z*0.02+t*v, p.x*0.02+t*v)));
        fogCol += mix( pixCol, denCol, density);
        return fogCol;
    }

    mat3 getCamera( in vec3 ro, in vec3 ta, float cr )
    {
        vec3 cw = normalize(ta-ro);
        vec3 cp = vec3(sin(cr), cos(cr),0.0);
        vec3 cu = normalize( cross(cw,cp) );
        vec3 cv =          ( cross(cu,cw) );
        return mat3( cu, cv, cw );
    }

    vec4 main(vec2 fragCoord) 
    {
        vec2 uv = -1.0 + 2.0 * fragCoord.xy/iResolution.xy ;
        //uv -= 0.5; // translate to the center of the screen
        uv.x *= iResolution.x / iResolution.y; // restore aspect ratio
        vec2 mouse = iMouse.xy/iResolution.xy;
        mouse -= 0.5;
        //define camera
        /*
        vec3 ro = vec3 (cos(mouse.x * MATH_2PI) * 10.0, 0.5, sin(mouse.x * MATH_2PI) * 10.0);
        vec3 ta = vec3 (0.0, 1.0, -2.0);
        */
        vec3 ro = iCameraPos;
        vec3 ta = vec3 (ro.x + cos(mouse.x * MATH_2PI) * 10.0, ro.y + 0.5,  ro.z + sin(mouse.x * MATH_2PI) * 10.0);
        mat3 cam = getCamera(ro, ta, 0.0);

        vec3 rd = normalize(mul(cam, vec3(uv, 1.0)));
        
        //draw scene
        vec3 color = vec3(0.0, 0.0, 0.0);
        vec4 hnor = castRay(ro, rd);
        vec3 p = ro + rd * hnor.x;
        
        if (hnor.x > EPSILON) {
            vec3 nor= getNormal(p) ;
            color += terrainColor(ro, rd, p, nor); 
        } else {
            color += sky(ro, rd);
        }
        
        color = fog(ro, rd, p, color, hnor.x);
        color = pow( color, vec3(1.0/2.2, 1.0/2.2, 1.0/2.2) );
        
        // Output to screen
        return vec4(color, 1.0);
       
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
