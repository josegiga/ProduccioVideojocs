Shader /*ase_name*/ "Hidden/HDRP/Decal" /*end*/
{
    Properties
    {
		/*ase_props*/
		[HideInInspector]_DrawOrder("_DrawOrder", Int) = 0
		[HideInInspector][Enum(Depth Bias, 0, View Bias, 1)] _DecalMeshBiasType("_DecalMeshBiasType", Int) = 0
		[HideInInspector]_DecalMeshDepthBias("_DecalMeshDepthBias", Float) = 0.0
		[HideInInspector]_DecalMeshViewBias("_DecalMeshViewBias", Float) = 0.0
        [HideInInspector]_DecalStencilWriteMask("_DecalStencilWriteMask", Int) = 16
        [HideInInspector]_DecalStencilRef("_DecalStencilRef", Int) = 16
		[HideInInspector][ToggleUI]_AffectAlbedo("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_AffectNormal("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_AffectAO("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_AffectMetal("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_AffectSmoothness("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_AffectEmission("Boolean", Float) = 1
		[HideInInspector]_DecalColorMask0("_DecalColorMask0", Int) = 0
		[HideInInspector]_DecalColorMask1("_DecalColorMask1", Int) = 0
		[HideInInspector]_DecalColorMask2("_DecalColorMask2", Int) = 0
		[HideInInspector]_DecalColorMask3("_DecalColorMask3", Int) = 0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

    SubShader
    {
		/*ase_subshader_options:Name=Additional Options
			Option:Affect BaseColor:false,true:true
				true:SetDefine:pragma shader_feature _ _MATERIAL_AFFECTS_ALBEDO
				false:RemoveDefine:pragma shader_feature _ _MATERIAL_AFFECTS_ALBEDO
				true:SetShaderProperty:_AffectAlbedo,[HideInInspector][ToggleUI]_AffectAlbedo("Boolean", Float) = 1
				false:SetShaderProperty:_AffectAlbedo,//[HideInInspector][ToggleUI]_AffectAlbedo("Boolean", Float) = 1
			Option:Affect Normal:false,true:true
				true:SetDefine:pragma shader_feature _ _MATERIAL_AFFECTS_NORMAL
				false:RemoveDefine:pragma shader_feature _ _MATERIAL_AFFECTS_NORMAL
				true:SetShaderProperty:_AffectNormal,[HideInInspector][ToggleUI]_AffectNormal("Boolean", Float) = 1
				false:SetShaderProperty:_AffectNormal,//[HideInInspector][ToggleUI]_AffectNormal("Boolean", Float) = 1
			Option:Affect Metal:false,true:true
				true:SetDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				false:RemoveDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				true:SetShaderProperty:_AffectMetal,[HideInInspector][ToggleUI]_AffectMetal("Boolean", Float) = 1
				false:SetShaderProperty:_AffectMetal,//[HideInInspector][ToggleUI]_AffectMetal("Boolean", Float) = 1
			Option:Affect AO:false,true:true
				true:SetDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				false:RemoveDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				true:SetShaderProperty:_AffectAO,[HideInInspector][ToggleUI]_AffectAO("Boolean", Float) = 1
				false:SetShaderProperty:_AffectAO,//[HideInInspector][ToggleUI]_AffectAO("Boolean", Float) = 1
			Option:Affect Smoothness:false,true:true
				true:SetDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				false:RemoveDefine:pragma shader_feature _ _MATERIAL_AFFECTS_MASKMAP
				true:SetShaderProperty:_AffectSmoothness,[HideInInspector][ToggleUI]_AffectSmoothness("Boolean", Float) = 1
				false:SetShaderProperty:_AffectSmoothness,//[HideInInspector][ToggleUI]_AffectSmoothness("Boolean", Float) = 1
			Option:Affect Emission:false,true:true
				true:SetDefine:_MATERIAL_AFFECTS_EMISSION
				true:IncludePass:DecalProjectorForwardEmissive
				true:IncludePass:DecalMeshForwardEmissive
				false:RemoveDefine:_MATERIAL_AFFECTS_EMISSION
				false:ExcludePass:DecalProjectorForwardEmissive
				false:ExcludePass:DecalMeshForwardEmissive
				true:SetShaderProperty:_AffectEmission,[HideInInspector][ToggleUI]_AffectEmission("Boolean", Float) = 1
				false:SetShaderProperty:_AffectEmission,//[HideInInspector][ToggleUI]_AffectEmission("Boolean", Float) = 1
			Option:Support LOD CrossFade:false,true:true
				true:SetDefine:pragma multi_compile _ LOD_FADE_CROSSFADE
				false:RemoveDefine:pragma multi_compile _ LOD_FADE_CROSSFADE
		*/
        Tags
        {
            "RenderPipeline"="HDRenderPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry+0"
        }

		HLSLINCLUDE
		#pragma target 4.5
		#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
		#pragma multi_compile_instancing

		struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
            float Metallic;
            float Occlusion;
            float Smoothness;
            float MAOSAlpha;
			float3 Emission;
        };
		ENDHLSL
		
		/*ase_pass*/
        Pass
		{
			/*ase_main_pass*/
			Name "DBufferProjector"
			Tags{"LightMode" = "DBufferProjector"}

            Stencil
			{
				WriteMask [_DecalStencilWriteMask]
				Ref [_DecalStencilRef]
				CompFront Always
				PassFront Replace
				CompBack Always
				PassBack Replace
			}
    
			Cull Front
			ZWrite Off
			ZTest Greater

			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 3 Zero OneMinusSrcColor

			ColorMask[_DecalColorMask0]
			ColorMask[_DecalColorMask1] 1
			ColorMask[_DecalColorMask2] 2
			ColorMask[_DecalColorMask3] 3

			HLSLPROGRAM
    
            #pragma vertex Vert
            #pragma fragment Frag
    
            #pragma multi_compile DECALS_3RT DECALS_4RT
    
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
    
            #define SHADERPASS SHADERPASS_DBUFFER_PROJECTOR
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/Decal.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"

			/*ase_pragma*/

            struct AttributesMesh
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
				/*ase_vdata:p=p;n=n;t=t*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

      		struct PackedVaryingsToPS
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				float3 positionRWS : TEXCOORD0;
				#endif
				/*ase_interp(1,):sp=sp.xyzw;rwp=tc0*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
            float _DrawOrder;
			int   _DecalMeshBiasType;
            float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            float _DecalStencilWriteMask;
            float _DecalStencilRef;
			#ifdef _MATERIAL_AFFECTS_ALBEDO
            float _AffectAlbedo;
			#endif
			#ifdef _MATERIAL_AFFECTS_NORMAL
            float _AffectNormal;
			#endif
            #ifdef _MATERIAL_AFFECTS_MASKMAP
            float _AffectAO;
			float _AffectMetal;
            float _AffectSmoothness;
			#endif
			#ifdef _MATERIAL_AFFECTS_EMISSION
            float _AffectEmission;
			#endif
            float _DecalColorMask0;
            float _DecalColorMask1;
            float _DecalColorMask2;
            float _DecalColorMask3;
            CBUFFER_END

			/*ase_globals*/

			/*ase_funcs*/
                
            void GetSurfaceData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, PositionInputs posInput, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)
                    float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    float fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    fragInputs.texCoord0.xy = fragInputs.texCoord0.xy * scale + offset;
                    fragInputs.texCoord1.xy = fragInputs.texCoord1.xy * scale + offset;
                    fragInputs.texCoord2.xy = fragInputs.texCoord2.xy * scale + offset;
                    fragInputs.texCoord3.xy = fragInputs.texCoord3.xy * scale + offset;
                    fragInputs.positionRWS = posInput.positionWS;
                    fragInputs.tangentToWorld[2].xyz = TransformObjectToWorldDir(float3(0, 1, 0));
                    fragInputs.tangentToWorld[1].xyz = TransformObjectToWorldDir(float3(0, 0, 1));
                #else
                    #ifdef LOD_FADE_CROSSFADE 
                    LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
                    #endif
    
                    float fadeFactor = 1.0;
                #endif
    
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
    
                #ifdef _MATERIAL_AFFECTS_EMISSION
                #endif
    
                #ifdef _MATERIAL_AFFECTS_ALBEDO
                    surfaceData.baseColor.xyz = surfaceDescription.BaseColor;
                    surfaceData.baseColor.w = surfaceDescription.Alpha * fadeFactor;
                #endif
    
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) 
                        surfaceData.normalWS.xyz = mul((float3x3)normalToWorld, surfaceDescription.NormalTS);
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, fragInputs.tangentToWorld));
                    #endif
    
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
                #else
                    #if (SHADERPASS == SHADERPASS_FORWARD_PREVIEW) 
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(float3(0.0, 0.0, 0.1), fragInputs.tangentToWorld));
                    #endif
                #endif
    
                #ifdef _MATERIAL_AFFECTS_MASKMAP
                    surfaceData.mask.z = surfaceDescription.Smoothness;
                    surfaceData.mask.w = surfaceDescription.MAOSAlpha * fadeFactor;
    
                    #ifdef DECALS_4RT
                        surfaceData.mask.x = surfaceDescription.Metallic;
                        surfaceData.mask.y = surfaceDescription.Occlusion;
                        surfaceData.MAOSBlend.x = surfaceDescription.MAOSAlpha * fadeFactor;
                        surfaceData.MAOSBlend.y = surfaceDescription.MAOSAlpha * fadeFactor;
                    #endif
                                                                  
                #endif
            }
                
			PackedVaryingsToPS Vert(AttributesMesh inputMesh  /*ase_vert_input*/)
			{
				PackedVaryingsToPS output;
					
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				/*ase_vert_code:inputMesh=AttributesMesh;output=PackedVaryingsToPS*/

				inputMesh.normalOS = /*ase_vert_out:Vertex Normal;Float3;10;-1;_VertexNormal*/inputMesh.normalOS/*end*/;
				inputMesh.tangentOS = /*ase_vert_out:Vertex Tangent;Float4;11;-1;_VertexTangent*/inputMesh.tangentOS/*end*/;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);
				
				output.positionCS = TransformWorldToHClip(positionRWS);
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				output.positionRWS = positionRWS;
				#endif
		
				return output;
			}

			void Frag( PackedVaryingsToPS packedInput,
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				OUTPUT_DBUFFER(outDBuffer)
			#else
				out float4 outEmissive : SV_Target0
			#endif
			/*ase_frag_input*/
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);
				
				FragInputs input;
                ZERO_INITIALIZE(FragInputs, input);
                input.tangentToWorld = k_identity3x3;
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				input.positionRWS = packedInput.positionRWS;
				#endif

                input.positionSS = packedInput.positionCS;

				DecalSurfaceData surfaceData;
				float clipValue = 1.0;
				float angleFadeFactor = 1.0;

				PositionInputs posInput;
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)    

				float depth = LoadCameraDepth(input.positionSS.xy);
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

				DecalPrepassData material;
				ZERO_INITIALIZE(DecalPrepassData, material);
				if (_EnableDecalLayers)
				{
					uint decalLayerMask = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal).x);

					DecodeFromDecalPrepass(posInput.positionSS, material);

					if ((decalLayerMask & material.decalLayerMask) == 0)
						clipValue -= 2.0;
				}

				
				float3 positionDS = TransformWorldToObject(posInput.positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0) + float3(0.5, 0.5, 0.5);
				if (!(all(positionDS.xyz > 0.0f) && all(1.0f - positionDS.xyz > 0.0f)))
				{
					clipValue -= 2.0; 
				}

			#ifndef SHADER_API_METAL
				clip(clipValue);
			#else
				if (clipValue > 0.0)
				{
			#endif

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				positionDS.xz = positionDS.xz * scale + offset;

				input.texCoord0.xy = positionDS.xz;
				input.texCoord1.xy = positionDS.xz;
				input.texCoord2.xy = positionDS.xz;
				input.texCoord3.xy = positionDS.xz;

				float3 V = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
				if (_EnableDecalLayers)
				{
					float2 angleFade = float2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.x > 0.0f)
					{
						float dotAngle = 1.0 - dot(material.geomNormalWS, normalToWorld[2].xyz);
						angleFadeFactor = 1.0 - saturate(dotAngle * angleFade.x + angleFade.y);
					}
				}

			#else
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(0, 0));
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
					float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
				#else
					float3 V = float3(1.0, 1.0, 1.0);
				#endif
			#endif

				/*ase_local_var:wp*/float3 positionWS = GetAbsolutePositionWS( posInput.positionWS );
				/*ase_local_var:rwp*/float3 positionRWS = posInput.positionWS;

				/*ase_local_var:uv0*/float4 texCoord0 = input.texCoord0;
				/*ase_local_var:uv1*/float4 texCoord1 = input.texCoord1;
				/*ase_local_var:uv2*/float4 texCoord2 = input.texCoord2;
				/*ase_local_var:uv3*/float4 texCoord3 = input.texCoord3;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				/*ase_frag_code:packedInput=PackedVaryingsToPS*/

				surfaceDescription.BaseColor = /*ase_frag_out:Base Color;Float3;0;-1;_Albedo*/float3( 0.7353569, 0.7353569, 0.7353569 )/*end*/;
				surfaceDescription.Alpha = /*ase_frag_out:Alpha;Float;1;-1;_AlphaAlbedo*/1/*end*/;
				surfaceDescription.NormalTS = /*ase_frag_out:Normal;Float3;2;-1;_Normal*/float3( 0, 0, 1 )/*end*/;
				surfaceDescription.NormalAlpha = /*ase_frag_out:Normal Alpha;Float;3;-1;_AlphaNormal*/1/*end*/;
				surfaceDescription.Metallic = /*ase_frag_out:Metallic;Float;4;-1;_Metallic*/0/*end*/;
				surfaceDescription.Occlusion = /*ase_frag_out:Occlusion;Float;5;-1;_Occlusion*/1/*end*/;
				surfaceDescription.Smoothness = /*ase_frag_out:Smoothness;Float;6;-1;_Smoothness*/0.5/*end*/;
				surfaceDescription.MAOSAlpha = /*ase_frag_out:MAOS Alpha;Float;7;-1;_MAOSOpacity*/1/*end*/;
				surfaceDescription.Emission = /*ase_frag_out:Emission;Float3;8;-1;_Emission*/float3( 0, 0, 0 )/*end*/;

				GetSurfaceData(surfaceDescription, input, V, posInput, angleFadeFactor, surfaceData);

			#if ((SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)) && defined(SHADER_API_METAL)
				} // if (clipValue > 0.0)

				clip(clipValue);
			#endif

			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);
			#else
				// Emissive need to be pre-exposed
				outEmissive.rgb = surfaceData.emissive * GetCurrentExposureMultiplier();
				outEmissive.a = 1.0;
			#endif
			}

            ENDHLSL
        }

		/*ase_pass*/
        Pass
		{
			/*ase_hide_pass*/
			Name "DecalProjectorForwardEmissive"
			Tags { "LightMode" = "DecalProjectorForwardEmissive" }

			Stencil
			{
				WriteMask[_DecalStencilWriteMask]
				Ref[_DecalStencilRef]
				Comp Always
				Pass Replace
			}

			Cull Front
			ZWrite Off
			ZTest Greater

			Blend 0 SrcAlpha One

			HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
    
            #define SHADERPASS SHADERPASS_FORWARD_EMISSIVE_PROJECTOR
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/Decal.hlsl"

			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"

			/*ase_pragma*/

            struct AttributesMesh
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
				/*ase_vdata:p=p;n=n;t=t*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

      		struct PackedVaryingsToPS
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				float3 positionRWS : TEXCOORD0;
				#endif
				/*ase_interp(1,):sp=sp.xyzw;rwp=tc0*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _DrawOrder;
			int   _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            float _DecalStencilWriteMask;
            float _DecalStencilRef;
            #ifdef _MATERIAL_AFFECTS_ALBEDO
            float _AffectAlbedo;
			#endif
            #ifdef _MATERIAL_AFFECTS_NORMAL
            float _AffectNormal;
			#endif
            #ifdef _MATERIAL_AFFECTS_MASKMAP
            float _AffectAO;
			float _AffectMetal;
            float _AffectSmoothness;
			#endif
            #ifdef _MATERIAL_AFFECTS_EMISSION
            float _AffectEmission;
			#endif
            float _DecalColorMask0;
            float _DecalColorMask1;
            float _DecalColorMask2;
            float _DecalColorMask3;
            CBUFFER_END

			/*ase_globals*/

			/*ase_funcs*/
                
            void GetSurfaceData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, PositionInputs posInput, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)
                    float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    float fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    fragInputs.texCoord0.xy = fragInputs.texCoord0.xy * scale + offset;
                    fragInputs.texCoord1.xy = fragInputs.texCoord1.xy * scale + offset;
                    fragInputs.texCoord2.xy = fragInputs.texCoord2.xy * scale + offset;
                    fragInputs.texCoord3.xy = fragInputs.texCoord3.xy * scale + offset;
                    fragInputs.positionRWS = posInput.positionWS;
                    fragInputs.tangentToWorld[2].xyz = TransformObjectToWorldDir(float3(0, 1, 0));
                    fragInputs.tangentToWorld[1].xyz = TransformObjectToWorldDir(float3(0, 0, 1));
                #else
                    #ifdef LOD_FADE_CROSSFADE 
                    LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
                    #endif
    
                    float fadeFactor = 1.0;
                #endif
    
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
    
                #ifdef _MATERIAL_AFFECTS_EMISSION
                    surfaceData.emissive.rgb = surfaceDescription.Emission.rgb * fadeFactor;
                #endif
    
                #ifdef _MATERIAL_AFFECTS_ALBEDO
                #endif
    
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) 
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                    #endif
    
                #else
                    #if (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                    #endif
                #endif
    
                #ifdef _MATERIAL_AFFECTS_MASKMAP
    
                    #ifdef DECALS_4RT
                    #endif
                                                                  
                #endif
            }
                
			PackedVaryingsToPS Vert(AttributesMesh inputMesh  /*ase_vert_input*/)
			{
				PackedVaryingsToPS output;
					
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				/*ase_vert_code:inputMesh=AttributesMesh;output=PackedVaryingsToPS*/

				inputMesh.normalOS = /*ase_vert_out:Vertex Normal;Float3;10;-1;_VertexNormal*/inputMesh.normalOS/*end*/;
				inputMesh.tangentOS = /*ase_vert_out:Vertex Tangent;Float4;11;-1;_VertexTangent*/inputMesh.tangentOS/*end*/;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);
				
				output.positionCS = TransformWorldToHClip(positionRWS);
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				output.positionRWS = positionRWS;
				#endif
		
				return output;
			}

			void Frag( PackedVaryingsToPS packedInput,
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				OUTPUT_DBUFFER(outDBuffer)
			#else
				out float4 outEmissive : SV_Target0
			#endif
			/*ase_frag_input*/
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);
				
				FragInputs input;
                ZERO_INITIALIZE(FragInputs, input);
                input.tangentToWorld = k_identity3x3;
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
				input.positionRWS = packedInput.positionRWS;
				#endif

                input.positionSS = packedInput.positionCS;

				DecalSurfaceData surfaceData;
				float clipValue = 1.0;
				float angleFadeFactor = 1.0;

				PositionInputs posInput;
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)    

				float depth = LoadCameraDepth(input.positionSS.xy);
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

				DecalPrepassData material;
				ZERO_INITIALIZE(DecalPrepassData, material);
				if (_EnableDecalLayers)
				{
					uint decalLayerMask = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal).x);

					DecodeFromDecalPrepass(posInput.positionSS, material);

					if ((decalLayerMask & material.decalLayerMask) == 0)
						clipValue -= 2.0;
				}

				
				float3 positionDS = TransformWorldToObject(posInput.positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0) + float3(0.5, 0.5, 0.5);
				if (!(all(positionDS.xyz > 0.0f) && all(1.0f - positionDS.xyz > 0.0f)))
				{
					clipValue -= 2.0; 
				}

			#ifndef SHADER_API_METAL
				clip(clipValue);
			#else
				if (clipValue > 0.0)
				{
			#endif

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				positionDS.xz = positionDS.xz * scale + offset;

				input.texCoord0.xy = positionDS.xz;
				input.texCoord1.xy = positionDS.xz;
				input.texCoord2.xy = positionDS.xz;
				input.texCoord3.xy = positionDS.xz;

				float3 V = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
				if (_EnableDecalLayers)
				{
					float2 angleFade = float2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.x > 0.0f)
					{
						float dotAngle = 1.0 - dot(material.geomNormalWS, normalToWorld[2].xyz);
						angleFadeFactor = 1.0 - saturate(dotAngle * angleFade.x + angleFade.y);
					}
				}

			#else
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(0, 0));
				#if defined(ASE_NEEDS_FRAG_RELATIVE_WORLD_POS)
					float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
				#else
					float3 V = float3(1.0, 1.0, 1.0);
				#endif
			#endif

				/*ase_local_var:wp*/float3 positionWS = GetAbsolutePositionWS( posInput.positionWS );
				/*ase_local_var:rwp*/float3 positionRWS = posInput.positionWS;

				/*ase_local_var:uv0*/float4 texCoord0 = input.texCoord0;
				/*ase_local_var:uv1*/float4 texCoord1 = input.texCoord1;
				/*ase_local_var:uv2*/float4 texCoord2 = input.texCoord2;
				/*ase_local_var:uv3*/float4 texCoord3 = input.texCoord3;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				/*ase_frag_code:packedInput=PackedVaryingsToPS*/

				surfaceDescription.BaseColor = /*ase_frag_out:Base Color;Float3;0;-1;_Albedo*/float3( 0.7353569, 0.7353569, 0.7353569 )/*end*/;
				surfaceDescription.Alpha = /*ase_frag_out:Alpha;Float;1;-1;_AlphaAlbedo*/1/*end*/;
				surfaceDescription.NormalTS = /*ase_frag_out:Normal;Float3;2;-1;_Normal*/float3( 0, 0, 1 )/*end*/;
				surfaceDescription.NormalAlpha = /*ase_frag_out:Normal Alpha;Float;3;-1;_AlphaNormal*/1/*end*/;
				surfaceDescription.Metallic = /*ase_frag_out:Metallic;Float;4;-1;_Metallic*/0/*end*/;
				surfaceDescription.Occlusion = /*ase_frag_out:Occlusion;Float;5;-1;_Occlusion*/1/*end*/;
				surfaceDescription.Smoothness = /*ase_frag_out:Smoothness;Float;6;-1;_Smoothness*/0.5/*end*/;
				surfaceDescription.MAOSAlpha = /*ase_frag_out:MAOS Alpha;Float;7;-1;_MAOSOpacity*/1/*end*/;
				surfaceDescription.Emission = /*ase_frag_out:Emission;Float3;8;-1;_Emission*/float3( 0, 0, 0 )/*end*/;

				GetSurfaceData(surfaceDescription, input, V, posInput, angleFadeFactor, surfaceData);

			#if ((SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)) && defined(SHADER_API_METAL)
				}

				clip(clipValue);
			#endif

			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);
			#else
				// Emissive need to be pre-exposed
				outEmissive.rgb = surfaceData.emissive * GetCurrentExposureMultiplier();
				outEmissive.a = 1.0;
			#endif
			}

            ENDHLSL
        }

		/*ase_pass*/
        Pass
		{
			/*ase_hide_pass*/
			Name "DBufferMesh"
			Tags { "LightMode" = "DBufferMesh" }
            

			Stencil
            {
                WriteMask [_DecalStencilWriteMask]
                Ref [_DecalStencilRef]
                CompFront Always
                PassFront Replace
                CompBack Always
                PassBack Replace
            }
    
			ZWrite Off
			ZTest LEqual

			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 3 Zero OneMinusSrcColor

			ColorMask[_DecalColorMask0]
			ColorMask[_DecalColorMask1] 1
			ColorMask[_DecalColorMask2] 2
			ColorMask[_DecalColorMask3] 3

            HLSLPROGRAM
    
            #pragma vertex Vert
            #pragma fragment Frag
    
            #pragma multi_compile DECALS_3RT DECALS_4RT
    
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
   
            #define SHADERPASS SHADERPASS_DBUFFER_MESH
    
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/Decal.hlsl"
			
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"
			
			#if ASE_SRP_VERSION >= 100301
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/DecalMeshBiasTypeEnum.cs.hlsl"
			#endif
			/*ase_pragma*/

            struct AttributesMesh
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
				/*ase_vdata:p=p;n=n;t=t;uv0=tc0*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			struct PackedVaryingsToPS
			{
				float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                float3 interp1 : TEXCOORD1;
                float4 interp2 : TEXCOORD2;
                float4 interp3 : TEXCOORD3;
				/*ase_interp(4,):sp=sp.xyzw;rwp=tc0;wn=tc1;wt=tc2;uv0=tc3*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
            CBUFFER_START(UnityPerMaterial)
            float _DrawOrder;
			int   _DecalMeshBiasType;
            float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            float _DecalStencilWriteMask;
            float _DecalStencilRef;
            #ifdef _MATERIAL_AFFECTS_ALBEDO
            float _AffectAlbedo;
			#endif
            #ifdef _MATERIAL_AFFECTS_NORMAL
            float _AffectNormal;
			#endif
            #ifdef _MATERIAL_AFFECTS_MASKMAP
            float _AffectAO;
			float _AffectMetal;
            float _AffectSmoothness;
			#endif
            #ifdef _MATERIAL_AFFECTS_EMISSION
            float _AffectEmission;
			#endif
            float _DecalColorMask0;
            float _DecalColorMask1;
            float _DecalColorMask2;
            float _DecalColorMask3;
            CBUFFER_END
       
	   		/*ase_globals*/

			/*ase_funcs*/

            void GetSurfaceData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, PositionInputs posInput, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)
                    float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    float fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    fragInputs.texCoord0.xy = fragInputs.texCoord0.xy * scale + offset;
                    fragInputs.texCoord1.xy = fragInputs.texCoord1.xy * scale + offset;
                    fragInputs.texCoord2.xy = fragInputs.texCoord2.xy * scale + offset;
                    fragInputs.texCoord3.xy = fragInputs.texCoord3.xy * scale + offset;
                    fragInputs.positionRWS = posInput.positionWS;
                    fragInputs.tangentToWorld[2].xyz = TransformObjectToWorldDir(float3(0, 1, 0));
                    fragInputs.tangentToWorld[1].xyz = TransformObjectToWorldDir(float3(0, 0, 1));
                #else
                    #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
                    #endif
    
                    float fadeFactor = 1.0;
                #endif
    
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
    
                #ifdef _MATERIAL_AFFECTS_EMISSION
                #endif
    
                #ifdef _MATERIAL_AFFECTS_ALBEDO
                    surfaceData.baseColor.xyz = surfaceDescription.BaseColor;
                    surfaceData.baseColor.w = surfaceDescription.Alpha * fadeFactor;
                #endif
    
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) 
                        surfaceData.normalWS.xyz = mul((float3x3)normalToWorld, surfaceDescription.NormalTS);
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, fragInputs.tangentToWorld));
                    #endif
    
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
                #else
                    #if (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(float3(0.0, 0.0, 0.1), fragInputs.tangentToWorld));
                    #endif
                #endif
    
                #ifdef _MATERIAL_AFFECTS_MASKMAP
                    surfaceData.mask.z = surfaceDescription.Smoothness;
                    surfaceData.mask.w = surfaceDescription.MAOSAlpha * fadeFactor;
    
                    #ifdef DECALS_4RT
                        surfaceData.mask.x = surfaceDescription.Metallic;
                        surfaceData.mask.y = surfaceDescription.Occlusion;
                        surfaceData.MAOSBlend.x = surfaceDescription.MAOSAlpha * fadeFactor;
                        surfaceData.MAOSBlend.y = surfaceDescription.MAOSAlpha * fadeFactor;
                    #endif
                                                                  
                #endif
            }

			PackedVaryingsToPS Vert(AttributesMesh inputMesh /*ase_vert_input*/ )
			{
				PackedVaryingsToPS output;

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				/*ase_vert_code:inputMesh=AttributesMesh;output=PackedVaryingsToPS*/

				inputMesh.normalOS = /*ase_vert_out:Vertex Normal;Float3;10;-1;_VertexNormal*/inputMesh.normalOS/*end*/;
				inputMesh.tangentOS = /*ase_vert_out:Vertex Tangent;Float4;11;-1;_VertexTangent*/inputMesh.tangentOS/*end*/;

				float3 worldSpaceBias = 0.0f;
				#if ASE_SRP_VERSION >= 100301
					if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
					{
						float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
						float3 V = GetWorldSpaceNormalizeViewDir(positionRWS);
						worldSpaceBias = V * (_DecalMeshViewBias);
					}
				#endif
				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS) + worldSpaceBias;
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				output.interp0.xyz = positionRWS;
				output.positionCS = TransformWorldToHClip(positionRWS);
				output.interp1.xyz = normalWS;
				output.interp2.xyzw = tangentWS;
				output.interp3.xyzw = inputMesh.uv0;

				#if ASE_SRP_VERSION >= 100301
					if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
					{
						#if UNITY_REVERSED_Z
							output.positionCS.z -= _DecalMeshDepthBias;
						#else
							output.positionCS.z += _DecalMeshDepthBias;
						#endif
					}
				#else	
					#if UNITY_REVERSED_Z
						output.positionCS.z -= _DecalMeshDepthBias;
					#else
						output.positionCS.z += _DecalMeshDepthBias;
					#endif
				#endif

				return output;
			}

			void Frag(  PackedVaryingsToPS packedInput,
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				OUTPUT_DBUFFER(outDBuffer)
			#else
				out float4 outEmissive : SV_Target0
			#endif
			/*ase_frag_input*/
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

                FragInputs input;
                ZERO_INITIALIZE(FragInputs, input);
                
                input.tangentToWorld = k_identity3x3;
                input.positionSS = packedInput.positionCS;
                
                input.positionRWS = packedInput.interp0.xyz;

                input.tangentToWorld = BuildTangentToWorld(packedInput.interp2.xyzw, packedInput.interp1.xyz);
                input.texCoord0 = packedInput.interp3.xyzw;

				DecalSurfaceData surfaceData;
				float clipValue = 1.0;
				float angleFadeFactor = 1.0;

				PositionInputs posInput;
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)    

				float depth = LoadCameraDepth(input.positionSS.xy);
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

				DecalPrepassData material;
				ZERO_INITIALIZE(DecalPrepassData, material);
				if (_EnableDecalLayers)
				{
					uint decalLayerMask = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal).x);

					DecodeFromDecalPrepass(posInput.positionSS, material);

					if ((decalLayerMask & material.decalLayerMask) == 0)
						clipValue -= 2.0;
				}

				float3 positionDS = TransformWorldToObject(posInput.positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0) + float3(0.5, 0.5, 0.5);
				if (!(all(positionDS.xyz > 0.0f) && all(1.0f - positionDS.xyz > 0.0f)))
				{
					clipValue -= 2.0;
				}

			#ifndef SHADER_API_METAL
				clip(clipValue);
			#else
				if (clipValue > 0.0)
				{
			#endif

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				positionDS.xz = positionDS.xz * scale + offset;

				input.texCoord0.xy = positionDS.xz;
				input.texCoord1.xy = positionDS.xz;
				input.texCoord2.xy = positionDS.xz;
				input.texCoord3.xy = positionDS.xz;

				float3 V = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

				if (_EnableDecalLayers)
				{
					float2 angleFade = float2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.x > 0.0f)
					{
						float dotAngle = 1.0 - dot(material.geomNormalWS, normalToWorld[2].xyz);
						angleFadeFactor = 1.0 - saturate(dotAngle * angleFade.x + angleFade.y);
					}
				}

			#else
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(0, 0));
				float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
			#endif

				/*ase_local_var:wp*/float3 positionWS = GetAbsolutePositionWS( posInput.positionWS );
				/*ase_local_var:rwp*/float3 positionRWS = posInput.positionWS;

				/*ase_local_var:uv0*/float4 texCoord0 = input.texCoord0;
				/*ase_local_var:uv1*/float4 texCoord1 = input.texCoord1;
				/*ase_local_var:uv2*/float4 texCoord2 = input.texCoord2;
				/*ase_local_var:uv3*/float4 texCoord3 = input.texCoord3;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				/*ase_frag_code:packedInput=PackedVaryingsToPS*/

				surfaceDescription.BaseColor = /*ase_frag_out:Base Color;Float3;0;-1;_Albedo*/float3( 0.7353569, 0.7353569, 0.7353569 )/*end*/;
				surfaceDescription.Alpha = /*ase_frag_out:Alpha;Float;1;-1;_AlphaAlbedo*/1/*end*/;
				surfaceDescription.NormalTS = /*ase_frag_out:Normal;Float3;2;-1;_Normal*/float3( 0, 0, 1 )/*end*/;
				surfaceDescription.NormalAlpha = /*ase_frag_out:Normal Alpha;Float;3;-1;_AlphaNormal*/1/*end*/;
				surfaceDescription.Metallic = /*ase_frag_out:Metallic;Float;4;-1;_Metallic*/0/*end*/;
				surfaceDescription.Occlusion = /*ase_frag_out:Occlusion;Float;5;-1;_Occlusion*/1/*end*/;
				surfaceDescription.Smoothness = /*ase_frag_out:Smoothness;Float;6;-1;_Smoothness*/0.5/*end*/;
				surfaceDescription.MAOSAlpha = /*ase_frag_out:MAOS Alpha;Float;7;-1;_MAOSOpacity*/1/*end*/;
				surfaceDescription.Emission = /*ase_frag_out:Emission;Float3;8;-1;_Emission*/float3( 0, 0, 0 )/*end*/;

				GetSurfaceData(surfaceDescription, input, V, posInput, angleFadeFactor, surfaceData);

			#if ((SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)) && defined(SHADER_API_METAL)
				} 

				clip(clipValue);
			#endif

			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);
			#else
				outEmissive.rgb = surfaceData.emissive * GetCurrentExposureMultiplier();
				outEmissive.a = 1.0;
			#endif
			}
            ENDHLSL
        }

		/*ase_pass*/
        Pass
		{
			/*ase_hide_pass*/
			Name "DecalMeshForwardEmissive"
			Tags{ "LightMode" = "DecalMeshForwardEmissive" }
    
			Stencil
			{
				WriteMask[_DecalStencilWriteMask]
				Ref[_DecalStencilRef]
				CompFront Always
				PassFront Replace
				CompBack Always
				PassBack Replace
			}

			ZWrite Off
			ZTest LEqual

			Blend 0 SrcAlpha One

            HLSLPROGRAM
    
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

            #define SHADERPASS SHADERPASS_FORWARD_EMISSIVE_MESH

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/Decal.hlsl"	
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"

			/*ase_pragma*/

            struct AttributesMesh
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
				/*ase_vdata:p=p;n=n;t=t;uv0=tc0*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			struct PackedVaryingsToPS
			{
				float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                float3 interp1 : TEXCOORD1;
                float4 interp2 : TEXCOORD2;
                float4 interp3 : TEXCOORD3;
				/*ase_interp(4,):sp=sp.xyzw;rwp=tc0;wn=tc1;wt=tc2;uv0=tc3*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
            CBUFFER_START(UnityPerMaterial)
            float _DrawOrder;
			int   _DecalMeshBiasType;
            float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            float _DecalStencilWriteMask;
            float _DecalStencilRef;
            #ifdef _MATERIAL_AFFECTS_ALBEDO
            float _AffectAlbedo;
			#endif
            #ifdef _MATERIAL_AFFECTS_NORMAL
            float _AffectNormal;
			#endif
            #ifdef _MATERIAL_AFFECTS_MASKMAP
            float _AffectAO;
			float _AffectMetal;
            float _AffectSmoothness;
			#endif
            #ifdef _MATERIAL_AFFECTS_EMISSION
            float _AffectEmission;
			#endif
            float _DecalColorMask0;
            float _DecalColorMask1;
            float _DecalColorMask2;
            float _DecalColorMask3;
            CBUFFER_END

	   		/*ase_globals*/

			/*ase_funcs*/

            void GetSurfaceData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, PositionInputs posInput, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)
                    float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    float fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    fragInputs.texCoord0.xy = fragInputs.texCoord0.xy * scale + offset;
                    fragInputs.texCoord1.xy = fragInputs.texCoord1.xy * scale + offset;
                    fragInputs.texCoord2.xy = fragInputs.texCoord2.xy * scale + offset;
                    fragInputs.texCoord3.xy = fragInputs.texCoord3.xy * scale + offset;
                    fragInputs.positionRWS = posInput.positionWS;
                    fragInputs.tangentToWorld[2].xyz = TransformObjectToWorldDir(float3(0, 1, 0));
                    fragInputs.tangentToWorld[1].xyz = TransformObjectToWorldDir(float3(0, 0, 1));
                #else
                    #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
                    #endif
    
                    float fadeFactor = 1.0;
                #endif
    
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
    
                #ifdef _MATERIAL_AFFECTS_EMISSION
                    surfaceData.emissive.rgb = surfaceDescription.Emission.rgb * fadeFactor;
                #endif
    
                #ifdef _MATERIAL_AFFECTS_ALBEDO
                    surfaceData.baseColor.xyz = surfaceDescription.BaseColor;
                    surfaceData.baseColor.w = surfaceDescription.Alpha * fadeFactor;
                #endif
    
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) 
                        surfaceData.normalWS.xyz = mul((float3x3)normalToWorld, surfaceDescription.NormalTS);
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_PREVIEW)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, fragInputs.tangentToWorld));
                    #endif
    
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
                #else
                    #if (SHADERPASS == SHADERPASS_FORWARD_PREVIEW) 
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(float3(0.0, 0.0, 0.1), fragInputs.tangentToWorld));
                    #endif
                #endif
    
                #ifdef _MATERIAL_AFFECTS_MASKMAP
                    surfaceData.mask.z = surfaceDescription.Smoothness;
                    surfaceData.mask.w = surfaceDescription.MAOSAlpha * fadeFactor;
    
                    #ifdef DECALS_4RT
                        surfaceData.mask.x = surfaceDescription.Metallic;
                        surfaceData.mask.y = surfaceDescription.Occlusion;
                        surfaceData.MAOSBlend.x = surfaceDescription.MAOSAlpha * fadeFactor;
                        surfaceData.MAOSBlend.y = surfaceDescription.MAOSAlpha * fadeFactor;
                    #endif
                                                                  
                #endif
            }

			PackedVaryingsToPS Vert(AttributesMesh inputMesh /*ase_vert_input*/ )
			{
				PackedVaryingsToPS output;

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				/*ase_vert_code:inputMesh=AttributesMesh;output=PackedVaryingsToPS*/
				
				inputMesh.normalOS = /*ase_vert_out:Vertex Normal;Float3;10;-1;_VertexNormal*/inputMesh.normalOS/*end*/;
				inputMesh.tangentOS = /*ase_vert_out:Vertex Tangent;Float4;11;-1;_VertexTangent*/inputMesh.tangentOS/*end*/;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				output.interp0.xyz = positionRWS;
				output.positionCS = TransformWorldToHClip(positionRWS);
				output.interp1.xyz = normalWS;
				output.interp2.xyzw = tangentWS;
				output.interp3.xyzw = inputMesh.uv0;

				return output;
			}

			void Frag(  PackedVaryingsToPS packedInput,
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				OUTPUT_DBUFFER(outDBuffer)
			#else
				out float4 outEmissive : SV_Target0
			#endif
			/*ase_frag_input*/
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

                FragInputs input;
                ZERO_INITIALIZE(FragInputs, input);
                
                input.tangentToWorld = k_identity3x3;
                input.positionSS = packedInput.positionCS;
                
                input.positionRWS = packedInput.interp0.xyz;

                input.tangentToWorld = BuildTangentToWorld(packedInput.interp2.xyzw, packedInput.interp1.xyz);
                input.texCoord0 = packedInput.interp3.xyzw;

				DecalSurfaceData surfaceData;
				float clipValue = 1.0;
				float angleFadeFactor = 1.0;

				PositionInputs posInput;
			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)    

				float depth = LoadCameraDepth(input.positionSS.xy);
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

				DecalPrepassData material;
				ZERO_INITIALIZE(DecalPrepassData, material);
				if (_EnableDecalLayers)
				{
					uint decalLayerMask = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal).x);

					DecodeFromDecalPrepass(posInput.positionSS, material);

					if ((decalLayerMask & material.decalLayerMask) == 0)
						clipValue -= 2.0;
				}

				float3 positionDS = TransformWorldToObject(posInput.positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0) + float3(0.5, 0.5, 0.5);
				if (!(all(positionDS.xyz > 0.0f) && all(1.0f - positionDS.xyz > 0.0f)))
				{
					clipValue -= 2.0;
				}

			#ifndef SHADER_API_METAL
				clip(clipValue);
			#else
				if (clipValue > 0.0)
				{
			#endif

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				positionDS.xz = positionDS.xz * scale + offset;

				input.texCoord0.xy = positionDS.xz;
				input.texCoord1.xy = positionDS.xz;
				input.texCoord2.xy = positionDS.xz;
				input.texCoord3.xy = positionDS.xz;

				float3 V = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

				if (_EnableDecalLayers)
				{
					float2 angleFade = float2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.x > 0.0f)
					{
						float dotAngle = 1.0 - dot(material.geomNormalWS, normalToWorld[2].xyz);
						angleFadeFactor = 1.0 - saturate(dotAngle * angleFade.x + angleFade.y);
					}
				}

			#else
				posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(0, 0));
				float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
			#endif

				/*ase_local_var:wp*/float3 positionWS = GetAbsolutePositionWS( posInput.positionWS );
				/*ase_local_var:rwp*/float3 positionRWS = posInput.positionWS;

				/*ase_local_var:uv0*/float4 texCoord0 = input.texCoord0;
				/*ase_local_var:uv1*/float4 texCoord1 = input.texCoord1;
				/*ase_local_var:uv2*/float4 texCoord2 = input.texCoord2;
				/*ase_local_var:uv3*/float4 texCoord3 = input.texCoord3;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				/*ase_frag_code:packedInput=PackedVaryingsToPS*/

				surfaceDescription.BaseColor = /*ase_frag_out:Base Color;Float3;0;-1;_Albedo*/float3( 0.7353569, 0.7353569, 0.7353569 )/*end*/;
				surfaceDescription.Alpha = /*ase_frag_out:Alpha;Float;1;-1;_AlphaAlbedo*/1/*end*/;
				surfaceDescription.NormalTS = /*ase_frag_out:Normal;Float3;2;-1;_Normal*/float3( 0, 0, 1 )/*end*/;
				surfaceDescription.NormalAlpha = /*ase_frag_out:Normal Alpha;Float;3;-1;_AlphaNormal*/1/*end*/;
				surfaceDescription.Metallic = /*ase_frag_out:Metallic;Float;4;-1;_Metallic*/0/*end*/;
				surfaceDescription.Occlusion = /*ase_frag_out:Occlusion;Float;5;-1;_Occlusion*/1/*end*/;
				surfaceDescription.Smoothness = /*ase_frag_out:Smoothness;Float;6;-1;_Smoothness*/0.5/*end*/;
				surfaceDescription.MAOSAlpha = /*ase_frag_out:MAOS Alpha;Float;7;-1;_MAOSOpacity*/1/*end*/;
				surfaceDescription.Emission = /*ase_frag_out:Emission;Float3;8;-1;_Emission*/float3( 0, 0, 0 )/*end*/;

				GetSurfaceData(surfaceDescription, input, V, posInput, angleFadeFactor, surfaceData);

			#if ((SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR)) && defined(SHADER_API_METAL)
				} 

				clip(clipValue);
			#endif

			#if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);
			#else
				outEmissive.rgb = surfaceData.emissive * GetCurrentExposureMultiplier();
				outEmissive.a = 1.0;
			#endif
			}
            ENDHLSL
        }
		/*ase_pass_end*/
    }
    CustomEditor "Rendering.HighDefinition.DecalGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}
