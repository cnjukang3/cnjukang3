keys = {"major": "PackageId", "minor": "Release", "product": "Name", "softwarecategory": "ApplicationType", "vendor": "Publisher", "version": "Version"}

def build_libraries(instanceId, libraries):
    response = []
    for library in libraries:
        if type(library) == list:
            response += build_libraries(instanceId, library)
        else:
            entry = {"asset_id_tattoo": instanceId, 'source_tool': 'AWS', "servicepack": "~NoData~"}
            for key in keys:
                entry[key] = library.get(keys.get(key), "~NoData~")
            response.append(entry)
    return response

def gather_resources(event, config_delegate):
    response = []
    instances = config_delegate.get_query_results("resourceId, configuration", f"resourceType = 'AWS::SSM::ManagedInstanceInventory' AND accountId = '{event.get('account')}'")
    for instance in instances:
        libraries = build_libraries(instance.get('resourceId'), list(instance.get("AWS:Application", {}).get('Content', {}).values()))
        event['overview']['library_count'] += len(libraries)
        response += libraries
    return response, instances

def swam(event, bucket, config_delegate):
    if event.get('hwam'):
        event.get('overview').update({'library_count': 0, 'no_swam_count': 0})
        response, raw = gather_resources(event, config_delegate)
        bucket.write_results(response, event.get('account'), 'swam')
        bucket.write_results(raw, event.get('account'), 'swam_raw')
    event.update({'phase': 'csm', 'config_delegate': False, 'role': True})
    event.get('phases').append('swam')
    return event
