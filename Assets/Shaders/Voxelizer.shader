﻿Shader "Unlit/Voxelizer" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		ZTest Always ZWrite Off
		Cull Off

		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#define VOXEL_CREATOR
			#include "Voxel.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 pos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul(UNITY_MATRIX_IT_MV, float4(v.normal, 0)).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos = o.vertex;
				return o;
			}
			
			void frag (v2f i) {
				fixed4 col = tex2D(_MainTex, i.uv);

				float3 ndcPos = i.pos.xyz / i.pos.w;
				float3 normalizedPos = float3(0.5 * (ndcPos.xy + 1.0), 1.0 - ndcPos.z);
				normalizedPos.y = (_ProjectionParams.x > 0 ? normalizedPos.y : 1.0 - normalizedPos.y);

				float3 pixelPos = _VoxelSize.xyz * normalizedPos;
				uint3 id = (uint3)floor(pixelPos);

				float3 n = normalize(i.normal);

				_VoxelColorTex[id] = col;
				_VoxelFaceTex[id] = abs(dot(n, float3(0,0,1)));
			}
			ENDCG
		}
	}
}
