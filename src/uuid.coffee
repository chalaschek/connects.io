CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split ''

uuid = (len, radix) ->
  chars = CHARS
  uuid = []
  radix = radix or chars.length

  if len
    # Compact form
    uuid[i] = chars[0 | Math.random()*radix] for i in [0..len] by 1
  else
    # rfc4122, version 4 form
    #rfc4122 requires these characters
    uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-'
    uuid[14] = '4'

    # Fill in random data.  At i==19 set the high bits of clock sequence as
    # per rfc4122, sec. 4.1.5
    for i in [0..36] by 1
      if  not uuid[i]
        r = 0 | Math.random()*16
        if i is 19
          uuid[i] = chars[(r & 0x3) | 0x8]
        else
          uuid[i] = chars[r]

  return uuid.join ''

module.exports =
  uuid : uuid