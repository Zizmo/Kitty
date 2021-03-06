package code
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class Map extends GameEntity
	{
		//The tilemap could be level specific if time permits.
		[Embed(source="../res/tilemap.png")]
		private static var _Tileset:Class;
		private static var _tileset:Bitmap;

		private var _collisionRects:Vector.<Rectangle>;
		private var _isLoaded:Boolean;
		private var _mapHeight:int;
		private var _mapWidth:int;
		private var _renderedMap:Bitmap;
		private var _tileSize:int;
		private var _tiles:Vector.<Vector.<Vector.<int>>>;

		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}

		/** Loads the map specified by the given string. */
		public function Map(mapFile:String)
		{
			_isLoaded = false;
			//Check whether the _tileset var needs to be initialized.
			if (_tileset == null)
				_tileset = new _Tileset();
			var request = new URLRequest(mapFile);
			var loader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				var loadedMap = new XML(e.target.data);
				parseMap(loadedMap);
				renderMap();
				_isLoaded = true;
			});
		}

		private function parseMap(xmlMap:XML):void
		{
			_mapWidth = xmlMap.@width;
			_mapHeight = xmlMap.@height;
			_tileSize = xmlMap.tileset.@tilewidth; //Assuming square tiles.
			_tiles = new Vector.<Vector.<Vector.<int>>>(xmlMap.layer.data.length());
			//Using a foreach loop gives strange results, so the more verbose
			//for loop version is used.
			for (var i = 0; i < xmlMap.layer.data.length(); i++)
			{
				_tiles[i] = stringTo2DVector(xmlMap.layer.data[i]);
			}
			var collisionObjects:XMLList = xmlMap.objectgroup.(@name == "collision")[0].object;
			_collisionRects = new Vector.<Rectangle>(collisionObjects.length());
			for (var i = 0; i < collisionObjects.length(); i++)
			{
				var obj = collisionObjects[i];
				_collisionRects[i] = new Rectangle(obj.@x, obj.@y, obj.@width, obj.@height);
			}
		}

		private function stringTo2DVector(s:String):Vector.<Vector.<int>>
		{
			var flatLayer = s.split(",").map(function(stringNum:String, index:int, arr:Array) {
				return int(stringNum);
			});
			var layer2D:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(_mapHeight);
			for (var i = 0; i < _mapHeight; i++)
			{
				layer2D[i] = Vector.<int>(flatLayer.slice(i * _mapWidth, (i + 1) * _mapWidth));
			}
			return layer2D;
		}

		private function renderMap():void
		{
			var renderedData = new BitmapData(_tileSize * _mapWidth,
				_tileSize * _mapHeight)

			for (var zIndex = 0; zIndex < _tiles.length; zIndex++)
			{
				var layer = _tiles[zIndex];
				for (var yIndex = 0; yIndex < _mapHeight; yIndex++)
				{
					for (var xIndex = 0; xIndex < _mapWidth; xIndex++)
					{
						//Tiled uses 0 for blank tiles, but that doesn't work
						//so nicely in calculations.
						var tid:int = layer[yIndex][xIndex] - 1;
						if (tid == -1)
							continue;
						var rect:Rectangle = new Rectangle(
							tid * _tileSize % _tileset.width,
							Math.floor((tid * _tileSize) / _tileset.width) * _tileSize,
							_tileSize,
							_tileSize);
						var dest:Point = new Point(
							xIndex * _tileSize,
							yIndex * _tileSize);
						renderedData.copyPixels(_tileset.bitmapData, rect, dest);
					}
				}
			}
			_renderedMap = new Bitmap(renderedData);
			addChild(_renderedMap);
		}

		public function isCollidingWithEnvironment(rect:Rectangle):Boolean
		{
			abortIfNotLoaded();
			return !_collisionRects.every(function(r:Rectangle, i:int, v:Vector.<Rectangle>) {
				return !r.intersects(rect);
			});
		}

		private function abortIfNotLoaded():void
		{
			if (_isLoaded == false)
				throw new Error("The map hasn't finished loading.");
		}
	}
}
