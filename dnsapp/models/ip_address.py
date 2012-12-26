IP4_PTR_SUFFIX = '.in-addr.arpa.'


def is_ipv4(ip):
    """Check wether given IPv4 is well formatted"""
    if not ip:
        return False
    try:
        nums = ip.split('.')
        if len(nums) != 4:
            return False
        for n in nums:
            if int(n) < 0 or int(n) > 255:
                return False
        return True
    except:
        return False


def ptr2ip(ptrdns):
    """Transform a PTR DNS to an IP or an IP prefix (or None)"""
    ptrdns = ptrdns.rstrip('.') + '.'
    if not ptrdns.endswith(IP4_PTR_SUFFIX):
        return None
    nums = ptrdns[0:-len(IP4_PTR_SUFFIX)].split('.')
    if len(nums) == 0 or len(nums) > 4:
        return None
    ip_parts = []
    try:
        for n in nums:
            if int(n) < 0 or int(n) > 255:
                return None
            ip_parts.insert(0, n)
    except ValueError:
        return None
    if len(ip_parts) < 4:
        ip_parts.append('')
    return '.'.join(ip_parts)


def ip2ptr(ip):
    """Transform an IP or an IP prefix to a PTR zone (or None)"""
    nums = ip.rstrip('.').split('.')
    if len(nums) == 0 or len(nums) > 4:
        return None
    ptr_parts = []
    try:
        for n in nums:
            if int(n) < 0 or int(n) > 255:
                return None
            ptr_parts.insert(0, n)
    except ValueError:
        return None
    return '.'.join(ptr_parts) + IP4_PTR_SUFFIX
