/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 * 
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.starling {
import spine.atlas.AtlasPage;
import spine.atlas.AtlasRegion;
import spine.atlas.TextureLoader;

import starling.textures.Texture;

import flash.display.Bitmap;
import flash.display.BitmapData;

public class StarlingTextureLoader implements TextureLoader {
	public var bitmapDatas:Object = {};
	public var singleBitmapData:BitmapData;

	/** @param bitmaps A Bitmap or BitmapData for an atlas that has only one page, or for a multi page atlas an object where the 
	 * key is the image path and the value is the Bitmap or BitmapData. */
	public function StarlingTextureLoader (bitmaps:Object) {
		if (bitmaps is BitmapData) {
			singleBitmapData = BitmapData(bitmaps);
			return;
		}
		if (bitmaps is Bitmap) {
			singleBitmapData = Bitmap(bitmaps).bitmapData;
			return;
		}
		
		for (var path:* in bitmaps) {
			var object:* = bitmaps[path];
			var bitmapData:BitmapData;
			if (object is BitmapData)
				bitmapData = BitmapData(object);
			else if (object is Bitmap)
				bitmapData = Bitmap(object).bitmapData;
			else
				throw new ArgumentError("Object for path \"" + path + "\" must be a Bitmap or BitmapData: " + object);
			bitmapDatas[path] = bitmapData;
		}
	}

	public function loadPage (page:AtlasPage, path:String) : void {
		var bitmapData:BitmapData = singleBitmapData || bitmapDatas[path];
		if (!bitmapData)
			throw new ArgumentError("BitmapData not found with name: " + path);
		page.rendererObject = Texture.fromBitmapData(bitmapData);
		page.width = bitmapData.width;
		page.height = bitmapData.height;
	}

	public function loadRegion (region:AtlasRegion) : void {
		var image:SkeletonImage = new SkeletonImage(Texture(region.page.rendererObject));
		if (region.rotate) {
			image.setTexCoordsTo(0, region.u, region.v2);
			image.setTexCoordsTo(1, region.u, region.v);
			image.setTexCoordsTo(2, region.u2, region.v2);
			image.setTexCoordsTo(3, region.u2, region.v);
		} else {
			image.setTexCoordsTo(0, region.u, region.v);
			image.setTexCoordsTo(1, region.u2, region.v);
			image.setTexCoordsTo(2, region.u, region.v2);
			image.setTexCoordsTo(3, region.u2, region.v2);
		}
		region.rendererObject = image;
	}

	public function unloadPage (page:AtlasPage) : void {
		Texture(page.rendererObject).dispose();
	}
}

}
