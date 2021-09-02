module lldbd;

/**
 * Initialize lldbd plugin global state
 *
 * This is needed before using any function of liblldbd.
 *
 * Returns: 0 on success, -1 otherwise
 */
extern(C) int lldbd_init()
{
	import core.runtime : rt_init;
	return rt_init() ? 0 : -1;
}

/**
 * Terminate lldbd plugin global state
 *
 * This free any memory allocated during the usage of liblldbd.
 *
 * Returns: 0 on success, -1 otherwise
 */
extern(C) int lldbd_terminate()
{
	import core.runtime : rt_term;
	return rt_term() ? 0 : -1;
}

/**
 * Demangle a given D mangled string
 *
 * A given valid D mangled string should be passed and optionally dst may
 * reference a destination range.
 *
 * Params:
 *   mangled = pointer to the mangled string
 *   length = length of the mangled string
 *   dst = destination buffer that must be a valid reference to a pointer,
 *         either `null` or a valid allocated range.
 *   dstlen = destination buffer length if a valid allocated range passed
 *         otherwise should pass `0`.
 *
 * Returns: 0 on success, -1 otherwise
 *
 * Note: If dst contains an invalid reference to a given pointer, undefined behaviour
 * may occur while dereferencing.
 */
extern(C) int lldbd_demangle(const(char)* mangled, size_t length, char** dst, size_t dstlen)
{
	// demangle symbol
	import core.demangle : demangle;
	auto ret = demangle(mangled[0 .. length], (*dst)[0 .. dstlen]);

	// check for failed demangling
	if(ret.ptr is mangled)
		return -1;

	// remove from GC if reallocated
	if (*dst !is ret.ptr)
	{
		import core.memory : GC;
		GC.removeRange(ret.ptr);
		*dst = ret.ptr;
	}

	return 0;
}
