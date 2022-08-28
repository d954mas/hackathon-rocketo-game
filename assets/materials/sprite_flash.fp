varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 flash;

void main()
{
    // Pre-multiply alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 spriteColor = texture2D(texture_sampler, var_texcoord0.xy) * tint_pm;
    gl_FragColor.rgb = (vec3(188.0/255.0,223.0/255.0,235.0/255.0) * flash.x + spriteColor.rgb * (1.0 - flash.x))*spriteColor.a;
    gl_FragColor.a = spriteColor.a;
}
