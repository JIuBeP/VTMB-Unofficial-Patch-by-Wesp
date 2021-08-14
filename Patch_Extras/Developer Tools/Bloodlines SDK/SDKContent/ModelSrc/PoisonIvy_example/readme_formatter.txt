Using MDL Formatter by DLLullu (PoisonIvy example)
--------------------------------------------------

You will need the Bloodlines SDK at least version 2.0 installed.

You will need Crowbar tool from this SDK with Alien Swarm MDL compiler integrated (StudioMDL-Sw) to compile Valve models.

And my Formatter (studioVTMB49k) that's now integrated with Crowbar too, to make a Bloodlines model out of a Valve model.


I included a SMD example (PoisonIvy player), so you can try out the thing.

Now the Valve model will need a skeleton from a Bloodlines model, PoisonIvy uses the Brujah model's skeleton (armature) with it's animations. So we must copy the .MDL and the .PHY from the Brujah model into a special folder ("xmodel/") near the model's source QC script for the Formatter ("poison_vtmb/xmodel" in this example). You should rename copied files to smaller names which must match first prefix of the model's reference SMD mesh name (a data before the "_" symbol). In the example below, I have renamed mine to "BrujahFH". I have changed some unused bones to make a pony tail on the Brujah model. Normally you will use a model with a pony tail like the number 2 or 3 Malkavian model but I started with the Brujah so...

What's all of this means: we are reusing the hitbox, the bones, the animations, the links to other animations and the physics - I changed nothing there. What I changed: the main mesh inside the model, the textures, a rewrite of the vtx. Oh and I added the eyes data from the Valve model, that is new, yeah. Before it was a pain to do.


For the eyes:
You must put the eyes data into the QC. The data is taken from Blender, you put the cursor on the center (or where you want the iris) of each eye and read the coordinates (X,Y,Z) of the cursor with +0.5 added to the Y coordinates. Look below, I have extracted the eyes data from the QC. For the eyes and shapes keys you need to use $model, not $bodygroup! You also need the eyes's attachment.

$model "girl" "brujahFH_poison_female_Armor_0_REF" {
//             ^______^ name used by the Formatter for the base model (xmodel/brujahFH.mdl).
//                                        X     Y+0.5   Z  =  position center of eyes in the mesh
        eyeball "eye_right" "Bip01 Head" -1.03 -2.89104 65.64 "eyeball_r" 1  4 "iris_unused" 0.63
        eyeball "eye_left"  "Bip01 Head"  1.31 -2.89104 65.64 "eyeball_l" 1 -4 "iris_unused" 0.63
}
//                                        sum\2 sum\2   sum\2
$attachment "eyes" "Bip01 Head"           0.14  -2.89   65.64 absolute


How To:
1. Open Crowbar tool from the SDK menu, choose the "Compile" tab.
2. Walk into the "SDKContent/ModelSrc/PoisonIvy_example/" folder of the installed SDK.
3. Drag or choose the QC from "poisonivy_vtmb/" in QC input, choose "Work folder" and set compiler to "Alien Swarm".
4. Compile the model. The compiled model will go into the SDK temporary folder (SDKBinaries/assets/models/...).
5. Now the Formatter tool will be *automatically* launched to convert Swarm-compiled model into the VTMB model.
6. Open your mod's /models/character/pc/... folder and find the newly created VTMB .mdl/.vtx/.phy model files.
7. Copy the materials/ content from this example into your mod's one, so our new model will use compiled textures.


// Readme adapted for the SDK by Psycho-A