#include <stdarg.h>

#include "ChipmunkObjC.h"

NSSet * ChipmunkObjectFlatten(id <ChipmunkObject> firstObject, ...)
{
	NSSet *result = [NSSet set];
	va_list args;
	va_start(args, firstObject);
		for(id <ChipmunkObject> obj = firstObject; obj != nil; obj = va_arg(args, id)){
			result = [result setByAddingObjectsFromSet:[obj chipmunkObjects]];
		}
	va_end(args);

	return result;
}
