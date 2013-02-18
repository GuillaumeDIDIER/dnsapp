import re
from django.core.exceptions import ValidationError
from django.core.validators import validate_ipv4_address, RegexValidator

IP4_ZONE_SUFFIX = '.in-addr.arpa'

# /8, /16 or /24 prefix
ip4_prefix_re = re.compile(r'^(25[0-5]|2[0-4]\d|[0-1]?\d?\d\.){1,3}$')
validate_ip4_prefix = RegexValidator(
    ip4_prefix_re, message=u"Enter a valid IPv4 prefix")


def ip_or_none(ip):
    """Return IP address if it is valide, None otherwise"""
    try:
        validate_ipv4_address(ip)
        return ip
    except ValidationError:
        return None


def ptr2ip(ptrdns):
    """Transform a PTR name to an IP or an IP prefix

    return None if the given name is invalid

    # Valid calls
    >>> ptr2ip('4.3.2.1.in-addr.arpa')
    '1.2.3.4'
    >>> ptr2ip('42.in-addr.arpa.')
    '42.'
    >>> ptr2ip('42.in-addr.arpa')
    '42.'
    >>> ptr2ip('1.42.in-addr.arpa')
    '42.1.'

    # Invalid calls
    >>> ptr2ip('.1.in-addr.arpa')
    >>> ptr2ip('2..1.in-addr.arpa')
    >>> ptr2ip('5.4.3.2.1.in-addr.arpa')
    >>> ptr2ip('4.3.2.1a.in-addr.arpa')
    """
    ptrdns = ptrdns.rstrip('.')
    if not ptrdns.endswith(IP4_ZONE_SUFFIX):
        return None
    nums = ptrdns[0:-len(IP4_ZONE_SUFFIX)].split('.')
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
    """Transform an IP or an IP prefix to a PTR zone

    return None if the given IP is invalid

    # Valid calls
    >>> ip2ptr('1.2.3.4')
    '4.3.2.1.in-addr.arpa'
    >>> ip2ptr('42.')
    '42.in-addr.arpa'
    >>> ip2ptr('42.1.')
    '1.42.in-addr.arpa'

    # Invalid calls
    >>> ip2ptr('.1.')
    >>> ip2ptr('1..2')
    >>> ip2ptr('1.2.3.4.5')
    >>> ip2ptr('1.2.3.4a')
    """
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
    return '.'.join(ptr_parts) + IP4_ZONE_SUFFIX

if __name__ == "__main__":
    import doctest
    doctest.testmod()
