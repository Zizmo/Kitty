package code
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	public class Map extends MovieClip
	{
		//The tilemap could be level specific if time permits.
		[Embed(source="../res/tilemap.png")]
		private static var _Tileset:Class;
		private static var _tileset:Bitmap;
		private var _tiles:Vector.<Vector.<Vector.<int>>>;
		private var _mapWidth:int;
		private var _mapHeight:int;

		/** Loads the map specified by the given string. */
		public function Map(mapFile:String)
		{
			//Check whether the _tileset var needs to be initialized.
			if (_tileset == null)
				_tileset = new _Tileset();
			var request = new URLRequest(mapFile);
			var loader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				var loadedMap = new XML(e.target.data);
				parseMap(loadedMap);
			});
		}

		private function parseMap(xmlMap:XML):void
		{
			_mapWidth = xmlMap.@width;
			_mapHeight = xmlMap.@height;
			_tiles = new Vector.<Vector.<Vector.<int>>>(xmlMap.layer.data.length());
			for (var i = 0; i < xmlMap.layer.data.length(); i++)
			{
				_tiles.push(stringTo2DVector(xmlMap.layer.data[i]));
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
				layer2D.push(Vector.<int>(flatLayer.slice(i * _mapWidth, (i + 1) * _mapWidth)));
			}
			return layer2D;
		}

		public function test():void
		{
			trace("width:", _mapWidth, "\nheight:", _mapHeight, "\n", _tiles);
		}
	}
}
