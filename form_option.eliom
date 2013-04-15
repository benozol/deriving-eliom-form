{shared{
  open Deriving_Form_base
}}

{client{

  let is_option_checked form =
    let checkbox =
      Js.Opt.get
        (Js.Opt.bind
           (form ## querySelector
              (Printf.ksprintf Js.string
                 " .field:nth-child(1) .%s"
                 form_option_checkbox_class))
           Dom_html.CoerceTo.input)
        (fun () -> Eliom_lib.error "set_checked: No checkbox")
    in
    Js.to_bool (checkbox ## checked)

  let rec is_option_checked_rec form =
    is_option_checked form &&
      (match parent_with_class form_option_class form with
        | None -> true
        | Some parent_form ->
          is_option_checked_rec parent_form)

  let rec set_checked =
    fun form ->
      try
      let inputs =
        form ## querySelectorAll
          (Printf.ksprintf Js.string
             "input:not([type='checkbox']):not(.%s)"
             component_not_required_class)
      in
      List.iter
        (fun input ->
          let checked =
            option_get' ~default:(fun () -> false)
              (option_map
                 (fun form ->
                   is_option_checked_rec form)
                 (parent_with_class form_option_class input))
          in
          let input =
            Js.Opt.get
              (Dom_html.CoerceTo.input input)
              (fun () -> Eliom_lib.error "set_checked: not an input")
          in
          input ## required <- Js.bool checked)
        (Dom.list_of_nodeList inputs);
      option_iter set_checked
        (parent_with_class form_option_class form)
      with exc ->
        Eliom_lib.error "ERROR: %s"
          (Printexc.to_string exc)
}}

{shared{
  module Make (Form : Form) = struct
    module Options = struct
      type a = Form.a option
      module Component_None = Deriving_Form_types.Form_unit
      module Component_Some = Form
      type param_names =
        [`One of string] Eliom_parameter.param_name *
          (Component_None.param_names * Component_Some.param_names)
      type deep_config = Component_None.config option * Component_Some.config option
      let default_deep_config = None, None
      include Template_data_unit
      type repr = string * (Component_None.repr option * Component_Some.repr option)
      let component_names = [ "None" ; "Some" ]
      let of_repr = function
        | ("None", (Some _, _)) -> None
        | ("Some", (_, Some component)) ->
            Some (Component_Some.of_repr component)
        | _ -> failwith "Form_option: of_repr"
      let to_repr =
        function
        | None -> ("None", ((Some (Component_None.to_repr ())), None))
        | Some component ->
          ("Some", (None, (Some (Component_Some.to_repr component))))
      let prefix_None prefix = prefix
      let prefix_Some prefix = prefix
      let params_type' prefix =
        prefix,
        Eliom_parameter.prod
          (Eliom_parameter.string (prefix ^ "||constructor"))
          (Eliom_parameter.prod
             (Eliom_parameter.opt
                (snd (Component_None.params_type' (prefix_None prefix))))
             (Eliom_parameter.opt
                (snd (Component_Some.params_type' (prefix_Some prefix)))))
      type ('arg, 'res) opt_component_configs_fun =
        ?none: Component_None.config ->
        ?some: Component_Some.config -> 'arg -> 'res
      let opt_component_configs_fun k ?none ?some arg = k (none, some) arg
      let default_template = default_template
      let variants : ((a, param_names, deep_config) variant) list =
        let project_None (none, some) = none
        and project_Some (none, some) = some
        in
        let module Component_None = struct
          type enclosing_a = a
          type enclosing_param_names = param_names
          type enclosing_deep_config = deep_config
          let project_default =
            function | None -> Some () | Some _ -> None
          let _ = project_default
          let project_param_names param_names =
            project_None (snd param_names)
          let _ = project_param_names
          let project_config = project_None
          let _ = project_config
          let is_constructor =
            function | None -> true | Some _ -> false
          let prefix = prefix_None
          include Component_None
        end in
        let module Component_Some = struct
          type enclosing_a = a
          type enclosing_param_names = param_names
          type enclosing_deep_config = deep_config
          let project_default =
            function
            | None -> None
            | Some component -> Some component
          let _ = project_default
          let project_param_names param_names =
            project_Some (snd param_names)
          let _ = project_param_names
          let project_config = project_Some
          let _ = project_config
          let is_constructor =
            function | None -> false | Some _ -> true
          let prefix = prefix_Some
          include Component_Some
        end in
        [ (module Component_None); (module Component_Some) ]
      let project_selector_param_name = fst
    end
    include Deriving_Form_sum.Make (Options)
  end
}}