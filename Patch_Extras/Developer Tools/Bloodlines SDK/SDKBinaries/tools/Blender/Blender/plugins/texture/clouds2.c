/**
 * $Id: clouds2.c,v 1.3 2006/11/22 15:53:45 hos Exp $
 *
 * ***** BEGIN GPL/BL DUAL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version. The Blender
 * Foundation also sells licenses for use in proprietary software under
 * the Blender License.  See http://www.blender.org/BL/ for information
 * about this.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 * The Original Code is Copyright (C) 2001-2002 by NaN Holding BV.
 * All rights reserved.
 *
 * The Original Code is: all of this file.
 *
 * Contributor(s): none yet.
 *
 * ***** END GPL/BL DUAL LICENSE BLOCK *****
 */
 
#include "math.h"
#include "plugin.h"

/* ******************** GLOBAL VARIABLES ***************** */

/* Texture name */

char name[24]= "Clouds2";

/* Subtype names must be less than 15 characters */

#define NR_TYPES	3
char stnames[NR_TYPES][16]= {"Intens", "Col", "Bump" };

/* Structure for buttons, 
 *  butcode      name           default  min  max  0
 */

VarStruct varstr[]= {
{	NUM|FLO,	"Offset",		-0.5, 	 -20.0, 20.0, ""}, 
{	NUM|INT,	"Depth",		8.0, 	1.0, 12.0, ""}, 
{	NUM|FLO,	"Scale",		2.2, 	-20.0, 20.0, ""},  
{	NUM|FLO,	"Falloff",		1.0, 	-20.0, 20.0, ""}
};

/* The cast struct is for input in the main doit function
   Varstr and Cast must have the same variables in the same order, 
   INCLUDING dummy variables for label fields. */ 

typedef struct Cast {
	float offset;
	int depth;
	float txtscale;
	float falloff;
} Cast;

/* result:
   Intensity, R, G, B, Alpha, nor.x, nor.y, nor.z
 */

float result[8];

/* cfra: the current frame */

float cfra;

int plugin_tex_doit(int, Cast*, float*, float*, float*);
void plugin_instance_init(Cast*);

/* ******************** Fixed functions ***************** */

int plugin_tex_getversion(void) 
{	
	return B_PLUGIN_VERSION;
}

void plugin_but_changed(int but) 
{
}

void plugin_init(void)
{
	
}

/* 
 * initialize any data for a particular instance of
 * the plugin here
 */
void plugin_instance_init(Cast *cast)
{
}

/* this function should not be changed: */

void plugin_getinfo(PluginInfo *info)
{
	info->name= name;
	info->stypes= NR_TYPES;
	info->nvars= sizeof(varstr)/sizeof(VarStruct);
	
	info->snames= stnames[0];
	info->result= result;
	info->cfra= &cfra;
	info->varstr= varstr;

	info->init= plugin_init;
	info->tex_doit=  (TexDoit) plugin_tex_doit;
	info->callback= plugin_but_changed;
	info->instance_init= (void (*)(void *)) plugin_instance_init;
}

/* ********************* the texture ******************** */


int plugin_tex_doit(int stype, Cast *cast, float *texvec, float *dxt, float *dyt)
{
	float val = 0.0;
	float a = 1.0;
	float p[3];
	float tv[3];
	int i;
	int res = TEX_INT;

	tv[0]=(texvec[0]+1.0)/2.0;
	tv[1]=(texvec[1]+1.0)/2.0;
	tv[2]=(texvec[2]+1.0)/2.0;

	p[0] = cast->txtscale * tv[0];
	p[1] = cast->txtscale * tv[1];
	p[2] = cast->txtscale * tv[2];
	
	for (i=0; i<cast->depth; i++) {
		val += a * hnoise(1.0, p[0], p[1], p[2]);
		
		p[0] *= 2.0;
		p[1] *= 2.0;
		p[2] *= 2.0;
		a *= 0.5;
	}
	
	/* always return this value */
	result[0] = CLAMP (val+cast->offset, 0.0, 1.0) * pow (fabs(sqrt(tv[0]*tv[0]+tv[1]*tv[1]+tv[2]*tv[2])), cast->falloff);
	
	if(stype==1) {
		/*
		 * this is r, g, b, a:
		 */
		result[1]= 0.5*result[0];
		result[2]= 1.0-val;
		result[3]= fsqrt(fabs(result[0]));
		result[4]= 1.0;

		res |= TEX_RGB;
	}
	if(stype==2) {
		/*
		 * This value is the displacement of the actual normal in 
		 * the Material calculation. 
		 */
		result[5]+= val;
		result[6]+= 1.0-val;
		result[7]= 0.0;

		res |= TEX_NOR;
	}
	
	return res;
}
	
