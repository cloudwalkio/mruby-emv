class EMVPlatform::EMV
  PPCOMP_OK            = 0
  PPCOMP_PROCESSING    = 1
  PPCOMP_NOTIFY        = 2

  PPCOMP_F1            = 4
  PPCOMP_F2            = 5
  PPCOMP_F3            = 6
  PPCOMP_F4            = 7
  PPCOMP_BACKSP        = 8

  PPCOMP_INVCALL       = 10
  PPCOMP_INVPARM       = 11
  PPCOMP_TIMEOUT       = 12
  PPCOMP_CANCEL        = 13
  PPCOMP_ALREADYOPEN   = 14
  PPCOMP_NOTOPEN       = 15
  PPCOMP_EXECERR       = 16
  PPCOMP_INVMODEL      = 17
  PPCOMP_NOFUNC        = 18
  PPCOMP_ERRMANDAT     = 19

  PPCOMP_TABEXP        = 20
  PPCOMP_TABERR        = 21
  PPCOMP_NOAPPLIC      = 22

  PPCOMP_PORTERR       = 30
  PPCOMP_COMMERR       = 31
  PPCOMP_UNKNOWNSTAT   = 32
  PPCOMP_RSPERR        = 33
  PPCOMP_COMMTOUT      = 34

  PPCOMP_INTERR        = 40
  PPCOMP_MCDATAERR     = 41
  PPCOMP_ERRPIN        = 42
  PPCOMP_NOCARD        = 43
  PPCOMP_PINBUSY       = 44

  PPCOMP_SAMERR        = 50
  PPCOMP_NOSAM         = 51
  PPCOMP_SAMINV        = 52

  PPCOMP_DUMBCARD      = 60
  PPCOMP_ERRCARD       = 61
  PPCOMP_CARDINV       = 62
  PPCOMP_CARDBLOCKED   = 63
  PPCOMP_CARDNAUTH     = 64
  PPCOMP_CARDEXPIRED   = 65
  PPCOMP_CARDERRSTRUCT = 66
  PPCOMP_CARDINVALIDAT = 67
  PPCOMP_CARDPROBLEMS  = 68
  PPCOMP_CARDINVDATA   = 69
  PPCOMP_CARDAPPNAV    = 70
  PPCOMP_CARDAPPNAUT   = 71
  PPCOMP_NOBALANCE     = 72
  PPCOMP_LIMITEXC      = 73
  PPCOMP_CARDNOTEFFECT = 74
  PPCOMP_VCINVCURR     = 75
  PPCOMP_ERRFALLBACK   = 76

  #TODO EMVPlatform custom

  # Possible flags to internal_text_show
  DSP_F_BHAVMASK  = 0x00000F00
  DSP_F_FREETXT   = 0x00000000 # Texto "livre" em pszTxt1, linhas separadas por '\r'. pszTxt2 não é usado.
  DSP_F_TXT2X16   = 0x00000100 # Texto de tamanho fixo 2x16 (32 caracteres sem separação) em pszTxt1. pszTxt2 não é usado.
  DSP_F_DATAENTRY = 0x00000200 # Título em pszTxt1 (pode ter mais de uma linha separada por '\r'). pszTxt2 é dado sendo editado.

  #Imagens / �cones a serem apresentados juntamente com o texto
  DSP_F_ICONMASK  = 0x000000FF
  DSP_F_ICORMC    = 0x00000001 # Remoção de cartão
  DSP_F_ICOPCRD   = 0x00000002 # Apresentação de cartão
  DSP_F_ICOCTLS   = 0x00000003 # Apresentação de cartão contactless
  DSP_F_ICOERROR  = 0x00000004 # Erro ou "warning"
  DSP_F_ICOSTANIM = 0x00000081 # Inicia animação (de passagem de tempo)
  DSP_F_ICOANIM   = 0x00000082 # Continua animação (de passagem de tempo)
  DSP_F_ICOLED    = 0x00000040 # 0x0000004x, onde x entre 0 e 4 led na tela, e F apaga Leds.

  #Textos fixos, para uso se aplica��o desejar alterar a original
  DSP_F_TXTNMASK      = 0x000F0000
  DSP_F_TXTPROCESSING = 0x00010000  # "PROCESSANDO"
  DSP_F_TXTINSSC      = 0x00020000  # "INSIRA OU PASSE O CARTAO"
  DSP_F_TXTINSPSC     = 0x00030000  # "APROXIME, INSIRA OU PASSE CARTAO"
  DSP_F_TXTSEL        = 0x00040000  # "SELECIONE"
  DSP_F_TXTAPPINV     = 0x00050000  # "APLICACAO INVALIDA"
  DSP_F_TXTINVPASS    = 0x00060000  # "SENHA INVALIDA"
  DSP_F_TXTBLKCARD    = 0x00070000  # "CARTAO BLOQUEADO"
  DSP_F_TXTBLKPASS    = 0x00080000  # "SENHA BLOQUEADA "
  DSP_F_TXTNEXTBLK    = 0x00090000  # "PROXIMO ERRO BLOQUEIA SENHA "
  DSP_F_TXTOKPASS     = 0x000A0000  # "SENHA VERIFICADA"
  DSP_F_TXTREMOVCARD  = 0x000B0000  # "RETIRE O CARTAO "
  DSP_F_TXTLTABLE     = 0x000C0000  # "ATUALIZANDO TABELAS"

  #Alinhamento do texto
  DSP_F_ALIGNMASK = 0x0000F000
  DSP_F_LEFT      = 0x00000000
  DSP_F_CENTER    = 0x00001000
  DSP_F_RIGHT     = 0x00002000

  class << self
    attr_reader :version, :menu_title_block, :menu_show_block, :text_show_block
    attr_accessor :fiber, :use_fiber
  end

  def self.version
    self.init unless @version
    @version || "0.0.0"
  end

  def self.init(port = "01")
    # TODO Scalone: Remove it from here, mrbgems shouldn't know DaFunk exists.
    include DaFunk::Helper
    ret = EMVPlatform::EMV.open(port)
    EMVPlatform::EMV::Pinpad.init
    @version = EMVPlatform::EMV::Pinpad.firmaware_version.to_s
    ret
  end

  def self.internal_menu_title(str)
    if self.menu_title_block
      self.menu_title_block.call(str)
    else
      @title = str
      4
    end
  end

  def self.emv_application_name_image_ready?(list = nil)
    (list.nil? || list.size == 2) && DaFunk::ParamsDat.file["emv_application_name_image"] == "1" &&
      FunkyEmv::Ui.bmp_exists?(:emv_selection_credit_debit) &&
      FunkyEmv::Ui.bmp_exists?(:emv_selected_credit) &&
      FunkyEmv::Ui.bmp_exists?(:emv_selected_debit)
  end

  def self.app_image_selection(list)
    list.each_with_index.inject({}) do |hash, app|
      index = app[1]
      name  = app[0].to_s.downcase
      if debit_message?(name)
        if touchscreen_supported?
          hash[index] = {:x => 20..225, :y => 200..320}
          hash[index][:debit_first] = true if list[0].to_s.downcase == name
        else
          hash[1] = index
        end
      elsif credit_message?(name)
        if touchscreen_supported?
          hash[index] = {:x => 20..225, :y => 90..190}
        else
          hash[0] = index
        end
      end
      hash
    end
  end

  def self.internal_menu_show(opts, bc_title = nil)
    list = opts.split("\r")
    if emv_application_name_image_ready?(list)
      if touchscreen_supported?
        options = app_image_selection(list)

        Device::Display.print_bitmap(FunkyEmv::Ui.bmp(:emv_selection_credit_debit))

        event = wait_touchscreen_or_keyboard_event(options,
                EmvTransaction.timeout * 1000, special_keys: [Device::IO::CANCEL])

        selected = parse_application_selected(event, options)
      else
        selected = menu_image(FunkyEmv::Ui.bmp(:emv_selection_credit_debit), app_image_selection(list),
                   timeout: (EmvTransaction.timeout * 1000))
      end
      ret = selected ? selected+1 : -1
    else
      selection = list.each_with_index.inject({}) do |hash, app|
        hash["#{app[1].to_i + 1}.#{app[0]}"] = app[1].to_i + 1; hash
      end
      mili = EmvTransaction.timeout * 1000
      selected = menu(@title || bc_title || I18n.t(:emv_select_application),
                      selection, timeout: mili, number: false)
      if selected == Device::IO::KEY_TIMEOUT
        ret = -1
      else
        ret = selected
      end
    end

    ret
  end

  def self.internal_get_pin(msg, inum)
    getc(200)
    amount = msg.split("\n").reject(&:empty?)[0].to_s
    amount["VALOR:"] = "" if amount.include?("VALOR:")
    if inum > 0
      Device::Display.print_line("*" * inum, STDOUT.x+3, 1)
    else
      FunkyEmv::Ui.display(:emv_enter_pin, :args => [amount.strip], :column => 1, :line => 1)
    end
    getc(200)
    0
  end

  def self.credit_message?(text)
    text.include?("credit") || text.include?("mastercard")
  end

  def self.debit_message?(text)
    text.include?("debit") || text.include?("maestro") || text.include?("electron")
  end

  def self.pax_display(text1)
    text = text1.to_s.downcase
    allow_selection_image = emv_application_name_image_ready?
    if text.include?("atualizando") && text.include?("tabelas")
    elsif text.include? "processando"
      FunkyEmv::Ui.display(:emv_processing, :line => 2, :column => 1)
    elsif allow_selection_image && text.include?("selecionado") && debit_message?(text)
      FunkyEmv::Ui.display(:emv_selected_debit)
    elsif allow_selection_image && text.include?("selecionado") && credit_message?(text)
      FunkyEmv::Ui.display(:emv_selected_credit)
    elsif text.include? "retire"
      FunkyEmv::Ui.display(:emv_remove_card, :line => 2)
    elsif allow_selection_image && (text.include?("aproxime") || text.include?("insira") || text.include?("passe"))
      FunkyEmv::Ui.display(:emv_input_card, :line => 2)
    else
      unless text1.to_s.strip.empty?
        Device::Display.clear
        puts text1
      end
    end
    true
  end

  def self.internal_text_show(flags, text1, text2)
    if self.text_show_block
      self.text_show_block.call(opts)
    else
      case Device::System.brand
      when "pax"
        pax_display(text1)
      when "gertec"
        if ! text1.to_s.empty?
          return if text1[0..7] == "\rRETIRE\r"
          Device::Display.clear
          #p "Text1 [#{text1.inspect}]"
          puts(*text1.split("\r")) if text1

          if (flags & DSP_F_DATAENTRY != 0)
            #p "Text2 [#{text2.inspect}]"
            puts(*text2.split("\r")) if text2
          end
        end
      else
        Device::Display.clear
        puts(*text1.split("\r")) if text1
        puts(*text2.split("\r")) if text2
      end
    end
  end

  def self.touchscreen_supported?
    MODELS_WITH_TOUCHSCREEN = ['s920']

    MODELS_WITH_TOUCHSCREEN.include?(Device::System.model)
  end

  def self.parse_application_selected(event, options)
    key   = event[1]
    event = event[0]

    if event == :timeout
      EmvTransaction.init_info[:result] = PPCOMP_TIMEOUT
      return
    end

    if event == :keyboard
      return if key == Device::IO::CANCEL

      if options[0].include?(:debit_first)
        return 1 if key == Device::IO::ONE_NUMBER # credit selected
        return 0 # debit selected
      end

      index = key.to_i-1 == -1 ? 0 : key.to_i-1
      options.keys[index]
    else
      options.select {|k, v| k == key}.shift[0]
    end
  end
end

