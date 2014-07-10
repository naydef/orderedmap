module orderedmap;

import std.algorithm;
import std.container;
import std.range;

public class OrderedMap(T)
{
	private DList!string _orderedKeys;
	private T[string] _hash;

	public int opApply(int delegate(ref T) dg)
	{
		int result = 0;
		foreach (key; _orderedKeys)
		{
			result = dg(_hash[key]);

			if (result)
				break;
		}

		return result;
	}

	public T opIndex(string key)
	{
		return _hash[key];
	}

	public int opIndexAssign(T val, string key)
	{
		if (key in _hash)
		{
			_orderedKeys.linearRemove(find(_orderedKeys[], key).take(1));
		}

		_hash[key] = val;
		_orderedKeys.stableInsertBack(key);

		return 0;
	}

	public bool remove(string key)
	{
		auto result = false;
		result = _hash.remove(key);
		_orderedKeys.linearRemove(find(_orderedKeys[], key).take(1));
		return result;
	}

	public T* opBinaryRight(string op:"in")(string rhs)
	{
		return rhs in _hash;
	}

	public ulong length()
	{
		return _hash.length;
	}
}

unittest 
{
	auto map = new OrderedMap!int();
	map["foo"] = 1;
	map["bar"] = 2;
	map["bar"] = 3;

	assert(map.length == 2);
	assert(map["bar"] == 3);
	assert("foo" in map);
	map.remove("foo");
	assert("foo" !in map);
	assert(map.length == 1);
}