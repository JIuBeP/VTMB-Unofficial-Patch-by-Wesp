
$ModelName "scenery/furniture/Chair_Basic/Chair_Basic.mdl"

$BodyGroup "Body"
{
	studio "Chair_Basic_REF"
}

$LOD 25
{
	replacemodel "Chair_Basic_REF.smd" "Chair_Basic_REF_lod1.smd"
}

$StaticProp

$IllumPosition 0 0 0

$EyePosition 0.5 -0.5 0.5

$CDMaterials "models\scenery\furniture\couch_basic\"

$CBox 0 0 0 0 0 0

$BBox -30.441 -42.366 -27.903 30.512 42.366 27.503

$Sequence "only_sequence" {
	"chair_basic_anims\only_sequence.smd"
	activity "ACT_IDLE" 1
	fps 30
}

$CollisionModel "chair_basic_physics.smd"
{
	$mass 20
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
