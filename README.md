# crf-check_mk-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['crf-check_mk']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### crf-check_mk::default

Include `crf-check_mk` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[crf-check_mk::default]"
  ]
}
```

## License and Authors

Author:: Crossroads Foundation Ltd (<itdept@crossroads.org.hk>)
