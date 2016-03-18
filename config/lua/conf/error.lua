module(..., package.seeall)

error_map = {
    [0] = '',
    [9000] = 'Unspecified error',
    [9001] = 'No data from backend service(s)',
    [9002] = 'Required parameters missing',
    [9003] = 'Invalid parameter value',
    [9004] = 'User is limited',
    [9005] = 'No available position for recommendation according to last_span and unread_status',
    [9006] = 'Temporarily limited',
    [9901] = 'UVE service name not defined',
    [9902] = 'UVE service does not exists',
    [9903] = 'No Render configured',
    [9904] = 'Invalid from value',
}
