package  {
	import flash.display.Sprite;
	import away3d.containers.Scene3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.loaders.Collada;
	import flash.events.Event;
	import away3d.core.base.Object3D;
	import away3d.loaders.Loader3D;
	import away3d.events.Loader3DEvent;
	import away3d.debug.AwayStats;
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.utils.MaterialLibrary;
	import away3d.loaders.data.MaterialData;
	import away3d.lights.AmbientLight3D;
	import away3d.materials.BitmapFileMaterial;
	import away3d.lights.PointLight3D;
	import away3d.core.session.BitmapSession;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.Dot3BitmapMaterial;
	import flash.geom.Vector3D;
	import away3d.materials.utils.NormalBumpMaker;
	
	public class Shirt extends Sprite {
		
		[Embed(source="assets/kit1_bm2.jpg")] private var BumpImage:Class;
	    private var bumpBitmap:Bitmap = new BumpImage();
		
		[Embed(source="assets/kit1_df.jpg")] private var TextureImage:Class;
	    private var textureBitmap:Bitmap = new TextureImage();
		
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var loader:Loader3D;
		private var model:Object3D;
		private var shirt:ObjectContainer3D;
		private var light:AmbientLight3D;
		private var light2:PointLight3D;
		private var texture:BitmapFileMaterial;
		
		private var bitmaps:Vector.<Bitmap>;
		private var currentBitmap:Bitmap;
		private var currentIndex:uint;
		
		public function Shirt() {
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
			
			bitmaps = new Vector.<Bitmap>();
			
            addChild(new AwayStats(view));
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new Camera3D({z:-1000});
			view = new View3D({
				scene:scene,
				camera:camera,
				session:new BitmapSession(1)
			});
			//scene.addLight(new AmbientLight3D());
			var light:DirectionalLight3D = new DirectionalLight3D({
				color:0xFFFFFF,
				ambient:0.8,
				diffuse:0.9,
				specular:0.05,
				direction: new Vector3D(500, 300, 200)
			});
			scene.addLight(light);
			/*var light2:PointLight3D = new PointLight3D({
				color:0xFFFFFF,
				ambient:0.5,
				diffuse:0.5,
				specular:0.1,
				scenePosition: new Vector3D(500, 300, 200)
			});
			scene.addLight(light2);*/
			//scene.addLight(light2);
			//scene.addLight(new AmbientLight3D());
			texture = new BitmapFileMaterial('assets/kit1_df.jpg');
			addChild(view);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//material = new ColorMaterial(0xCC0000);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			loader = Collada.load('assets/shirt3.dae', {shading: true});
			loader.addOnSuccess(onShirtLoaded);
			loader.centerMeshes();
			loader.autoLoadTextures = true;
		}
		
		private function onShirtLoaded(e:Loader3DEvent):void
		{
			model = Object3D(e.loader.handle);
			//model.scale(3);
			var materials:MaterialLibrary = model.materialLibrary;
			for (var i:* in materials) {
				var mat:MaterialData = materials[i];
				trace (i, mat);
			}
			var normalMaker:NormalBumpMaker = new NormalBumpMaker();
		    var normalBitmapData:BitmapData = normalMaker.convertToNormalMap(bumpBitmap.bitmapData);
			//var mat:MaterialData = model.materialLibrary.getMaterial("Holland___1st_kit-material");
            //mat.material = new Dot3BitmapMaterial(textureBitmap.bitmapData, normalBitmapData,{smooth:true});
			//model.materialLibrary.material(texture);
			//model.x = model.objectWidth * -0.5;
			//model.y = -60;
			//model.z = 50;
			
			shirt = new ObjectContainer3D();
			shirt.addChild(model);
			//shirt.z = 250;
			
			view.scene.addChild(shirt);
      		loader.removeOnSuccess(onShirtLoaded);
			
			addEventListener(Event.ENTER_FRAME, onTick);
			
			/*var materials:MaterialLibrary = model.materialLibrary;
			for (var i:* in materials) {
				var mat:MaterialData = materials[i];
				mat.
				trace (i, mat);
				for (var j:* in mat) {
					trace ('-', j, mat[j]);
				}
			}*/
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onTick( e:Event ):void
		{
			var sw:uint = stage.stageWidth;
			var sh:uint = stage.stageHeight;
			if (shirt.rotationY < 360)
			{
				shirt.rotationY += 3;
				view.render();
				//var bm:Bitmap = new Bitmap(view.getBitmapData())
				var bounds:Rectangle = view.getBounds(view);
				var bmd:BitmapData = new BitmapData(sw, sh);
					bmd.draw(view, new Matrix(1,0,0,1,-bounds.x,-bounds.y));
				var bm:Bitmap = new Bitmap(bmd);
				bitmaps.push(bm);
			}
			else
			{
				if (!currentBitmap)
				{
					removeChild(view);
					currentIndex = 0;
				}
				else
				{
					removeChild(currentBitmap);
					currentIndex ++;
					if (currentIndex >= bitmaps.length)
						currentIndex = 0;
				}
				currentBitmap = bitmaps[currentIndex];
				//currentBitmap.x = sw * 0.5;
				//currentBitmap.y = sw * 0.5;
				addChild(currentBitmap);
			}
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            //SignatureBitmap.y = stage.stageHeight - Signature.height;
		}

	}
	
}
